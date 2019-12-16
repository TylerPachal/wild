defmodule Wild.Tokenizer do

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

    quote do
      @special_bytes [unquote(question_mark), unquote(asterisk)]

      def tokenize_subject(subject) do
        split(subject)
      end

      def tokenize_pattern(pattern) do
        bytes = split(pattern)

        # Zipping the list with an offset copy of itself so when we are iterating
        # we can see the next byte.  This is helpful for when we run into a
        # backslash and need to know if it is escaping a special character.
        all_pairs = Enum.zip([nil | bytes], bytes ++ [nil])
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
        # along with everything we thought would be a class.
        acc =
          case class do
            nil -> acc
            not_actually_a_class -> not_actually_a_class ++ [unquote(left_square_bracket) | acc]
          end

        # We have been appending to the head of the accumulated list the whole time
        # but we need to keep the original order, so we must reverse the
        # accumulated list.
        Enum.reverse(acc)
      end

      # Not in a class - A special byte preceeded by a backslash should be treated
      # literally
      defp do_tokenize_pattern([{unquote(backslash), next_byte}, _special_byte | tail], acc, class = nil) when next_byte in @special_bytes do
        do_tokenize_pattern(tail, [next_byte | acc], class)
      end

      # Not in a class - A special byte not being escaped should be treated
      # with special characteristics
      defp do_tokenize_pattern([{special_byte, _next_byte} | tail], acc, class = nil) when special_byte in @special_bytes do
        do_tokenize_pattern(tail, [{:special, special_byte} | acc], class)
      end

      # Starting a new class
      defp do_tokenize_pattern([{unquote(left_square_bracket), _next_byte} | tail], acc, _class = nil) do
        do_tokenize_pattern(tail, acc, [])
      end

      # Not in a class - A non-special byte
      defp do_tokenize_pattern([{byte, _next_byte} | tail], acc, class = nil) do
        do_tokenize_pattern(tail, [byte | acc], class)
      end

      # In a class - The closing bracket may be part of a class if it is the first
      # member of the class
      defp do_tokenize_pattern([{unquote(right_square_bracket), _next_byte} | tail], acc, _class = []) do
        do_tokenize_pattern(tail, acc, [unquote(right_square_bracket)])
      end

      # Ending the current class
      defp do_tokenize_pattern([{unquote(right_square_bracket), _next_byte} | tail], acc, class) when is_list(class) do
        class =
          class
          |> Enum.reverse()
          |> normalize_class()

        do_tokenize_pattern(tail, [class | acc], nil)
      end

      # In a class - Regular byte
      defp do_tokenize_pattern([{byte, _next_byte} | tail], acc, class) when is_list(class) do
        do_tokenize_pattern(tail, acc, [byte | class])
      end


      # During the tokenization we build up classes as list of bytes.  We transform
      # these lists into MapSets for performance while taking care to also respect
      # classes that contain ranges of bytes.
      #
      # Expects that the bytes are in their original order (only really matters for
      # ranges though)
      defp normalize_class(class) do
        # Zipping the list with a negative and positive offset of itself so we can
        # iterate and have a copy of the leadign and trailing byte.
        all_zipped =
          Enum.zip([nil, nil | class], [nil | class])
          |> Enum.zip(class ++ [nil])
          |> Enum.map(fn {{prev, cur}, next} -> {prev, cur, next} end)

        [_ | zipped] = all_zipped

        zipped
        |> normalize_class([])
        |> MapSet.new()
      end

      # Base case - turn list into MapSet
      defp normalize_class([], acc) do
        MapSet.new(acc)
      end

      # A dash at the start of the class should be treated literally
      defp normalize_class([{nil, unquote(dash), _next} | tail], acc) do
        normalize_class(tail, [unquote(dash) | acc])
      end

      # A dash at the end of the class should be treated literally
      defp normalize_class([{_prev, unquote(dash), nil} | tail], acc) do
        normalize_class(tail, [unquote(dash) | acc])
      end

      # A range, expand it and and each member
      defp normalize_class([{range_start, unquote(dash), range_end} | tail], acc) do
        normalize_class(tail, range_to_list(range_start, range_end) ++ acc)
      end

      # A non-special byte
      defp normalize_class([{_prev, byte, _next} | tail], acc) do
        normalize_class(tail, [byte | acc])
      end
    end
  end
end
