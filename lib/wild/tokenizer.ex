defmodule Wild.Tokenizer do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    question_mark = Module.get_attribute(__CALLER__.module, :question_mark)
    asterisk = Module.get_attribute(__CALLER__.module, :asterisk)
    backslash = Module.get_attribute(__CALLER__.module, :backslash)
    left_square_bracket = Module.get_attribute(__CALLER__.module, :left_square_bracket)
    right_square_bracket = Module.get_attribute(__CALLER__.module, :right_square_bracket)
    dash = Module.get_attribute(__CALLER__.module, :dash)
    exclamation_mark = Module.get_attribute(__CALLER__.module, :exclamation_mark)

    quote do
      @special_tokens [unquote(question_mark), unquote(asterisk)]
      @escabale_tokens [unquote(backslash) | @special_tokens]

      def tokenize_subject(subject) do
        split(subject)
      end

      def tokenize_pattern(pattern) do
        tokens = split(pattern)

        # Zipping the list with an offset copy of itself so when we are iterating
        # we can see the next token.  This is helpful for when we run into a
        # backslash and need to know if it is escaping a special character.
        all_pairs = Enum.zip([nil | tokens], tokens ++ [nil])
        [_head | pairs] = all_pairs
        accumulated = []
        class = nil
        do_tokenize_pattern(pairs, accumulated, class)
      end


      # Takes the pattern and tokenizes it for the main matching functionality.
      #  - Checks for special characters (escaped or not)
      #  - Turns classes into MapSets
      defp do_tokenize_pattern(pairs, acc, class)

      # Base case
      defp do_tokenize_pattern([], acc, class) do
        # If the class is non-nil that means that the most recent open bracket we
        # encountered was never closed, and it should be interpreted literally,
        # along with everything we thought would be a class.  Any special
        # characters in the not-class also need to be converted to special.
        acc =
          case class do
            nil ->
              acc

            not_actually_a_class ->
              tokens =
                Enum.map(not_actually_a_class, fn
                  t when t in @special_tokens -> {:special, t}
                  t -> t
                end)
              tokens ++ [unquote(left_square_bracket) | acc]
          end

        # We have been appending to the head of the accumulated list the whole time
        # but we need to keep the original order, so we must reverse the
        # accumulated list.
        {:ok, Enum.reverse(acc)}
      end

      # Not in a class - An escapable token preceeded by a backslash should be
      # treated literally
      defp do_tokenize_pattern([{unquote(backslash), next_token}, _token | tail], acc, class = nil) when next_token in @escabale_tokens do
        do_tokenize_pattern(tail, [next_token | acc], class)
      end

      # If the backslash token is not preceeding an escapable character then
      # this pattern is invalid
      defp do_tokenize_pattern([{unquote(backslash), _next_token} | _tail], _acc, _class) do
        {:error, :invalid_escape_sequence}
      end

      # Not in a class - A special token not being escaped should be treated
      # with special characteristics
      defp do_tokenize_pattern([{special_token, _next_token} | tail], acc, class = nil) when special_token in @special_tokens do
        do_tokenize_pattern(tail, [{:special, special_token} | acc], class)
      end

      # Starting a new class
      defp do_tokenize_pattern([{unquote(left_square_bracket), _next_token} | tail], acc, _class = nil) do
        do_tokenize_pattern(tail, acc, [])
      end

      # Not in a class - A non-special token
      defp do_tokenize_pattern([{token, _next_token} | tail], acc, class = nil) do
        do_tokenize_pattern(tail, [token | acc], class)
      end

      # In a class - The closing bracket may be part of a class if it is the first
      # member of the class
      defp do_tokenize_pattern([{unquote(right_square_bracket), _next_token} | tail], acc, _class = []) do
        do_tokenize_pattern(tail, acc, [unquote(right_square_bracket)])
      end

      # Ending the current class - if it only contains a negation then it is invalid
      defp do_tokenize_pattern([{unquote(right_square_bracket), _next_token} | tail], acc, ["!"]) do
        {:error, :invalid_class}
      end

      # Ending the current class
      defp do_tokenize_pattern([{unquote(right_square_bracket), _next_token} | tail], acc, class) when is_list(class) do
        normalized_class_result =
          class
          |> Enum.reverse()
          |> normalize_class()

        case normalized_class_result do
          {:ok, normalized_class} ->
            do_tokenize_pattern(tail, [normalized_class | acc], nil)
          error ->
            error
        end
      end

      # In a class - Regular token
      defp do_tokenize_pattern([{token, _next_token} | tail], acc, class) when is_list(class) do
        do_tokenize_pattern(tail, acc, [token | class])
      end


      # During the tokenization we build up classes as list of tokens.
      # We transform these lists into MapSets for performance while taking care
      # to also respect classes that contain ranges of tokens.
      #
      # Expects that the tokens are in the original order that they appeared
      # in the pattern so that ranges and negated classes will work properly.
      defp normalize_class(class) do
        # Check if the class is negated
        {map_set, class} =
          case class do
            [unquote(exclamation_mark) | tail] ->
              {MapSet.new([:negated]), tail}
            _ ->
              {MapSet.new(), class}
          end

        # Zipping the list with a negative and positive offset of itself so we can
        # iterate and have a copy of the leading and trailing token.
        zipped =
          Enum.zip([nil, nil | class], [nil | class])
          |> Enum.zip(class ++ [nil])
          |> Enum.map(fn {{prev, cur}, next} -> {prev, cur, next} end)
          |> Enum.drop(1)

        case do_normalize_class(zipped, []) do
          {:ok, normalized} -> {:ok, Enum.into(normalized, map_set)}
          {:error, _} -> {:error, :invalid_class}
        end
      end

      # Base case - turn list into MapSet
      defp do_normalize_class([], acc) do
        {:ok, MapSet.new(acc)}
      end

      # A dash at the start of the class should be treated literally
      defp do_normalize_class([{nil, unquote(dash), _next} | tail], acc) do
        do_normalize_class(tail, [unquote(dash) | acc])
      end

      # A dash at the end of the class should be treated literally
      defp do_normalize_class([{_prev, unquote(dash), nil} | tail], acc) do
        do_normalize_class(tail, [unquote(dash) | acc])
      end

      # A range, expand it and and each member
      defp do_normalize_class([{range_start, unquote(dash), range_end} | tail], acc) when range_start <= range_end do
        do_normalize_class(tail, range_to_list(range_start, range_end) ++ acc)
      end
      # An invalid range, the start needs to be less-than-or-equal-to the end
      defp do_normalize_class([{_range_start, unquote(dash), _range_end} | _tail], _acc) do
        {:error, :invalid_range}
      end

      # A non-special token
      defp do_normalize_class([{_prev, token, _next} | tail], acc) do
        do_normalize_class(tail, [token | acc])
      end
    end
  end
end
