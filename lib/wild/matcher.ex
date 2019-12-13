defmodule Wild.Matcher do

  defmacro __using__(_) do
    quote do
      use Wild.Tokenizer
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    question_mark = Module.get_attribute(__CALLER__.module, :question_mark)
    asterisk = Module.get_attribute(__CALLER__.module, :asterisk)

    quote do
      alias Wild.LookupTable

      def match?(subject, pattern, _opts) do
        tokenized_subject = tokenize_subject(subject)
        tokenized_pattern = tokenize_pattern(pattern)

        subject_length = Enum.count(tokenized_subject)
        pattern_length = Enum.count(tokenized_pattern)

        # Create an empty table, initialize [0, 0] to true, then fill the top row
        # based on * characters in the pattern
        table =
          LookupTable.create(subject_length, pattern_length)
          |> LookupTable.set(0, 0, true)
          |> init_top_row(tokenized_pattern)

        iterations =
          for {subject_char, subject_index} <- Enum.with_index(tokenized_subject),
              {pattern_char, pattern_index} <- Enum.with_index(tokenized_pattern),
          into: [] do
            {subject_char, subject_index, pattern_char, pattern_index}
          end

        table = fill_table(table, iterations)
        LookupTable.get(table, subject_length, pattern_length)
      end

      # Check for "*" in the pattern and fill the top row of the table
      defp init_top_row(table, pattern) do
        pattern
        |> Enum.with_index()
        |> Enum.reduce(table, fn
          {{:special, unquote(asterisk)}, index}, table ->
            value = LookupTable.get(table, 0, index)
            LookupTable.set(table, 0, index + 1, value)
          _, table ->
            table
        end)
      end

      defp fill_table(table, []) do
        table
      end
      defp fill_table(table, [{_subject_char, subject_index, {:special, unquote(asterisk)}, pattern_index} | iterations]) do
        value = LookupTable.get(table, subject_index + 1, pattern_index) || LookupTable.get(table, subject_index, pattern_index + 1)
        table = LookupTable.set(table, subject_index + 1, pattern_index + 1, value)
        fill_table(table, iterations)
      end
      defp fill_table(table, [{_subject_char, subject_index, {:special, unquote(question_mark)}, pattern_index} | iterations]) do
        value = LookupTable.get(table, subject_index, pattern_index)
        table = LookupTable.set(table, subject_index + 1, pattern_index + 1, value)
        fill_table(table, iterations)
      end
      defp fill_table(table, [{char, subject_index, char, pattern_index} | iterations]) do
        fill_table_exact_match(table, subject_index, pattern_index, iterations)
      end
      defp fill_table(table, [{subject_char, subject_index, class, pattern_index} | iterations]) when is_map(class) do
        # Class case
        if MapSet.member?(class, subject_char) do
          fill_table_exact_match(table, subject_index, pattern_index, iterations)
        else
          fill_table(table, iterations)
        end
      end
      defp fill_table(table, [i | iterations]) do
        fill_table(table, iterations)
      end

      defp fill_table_exact_match(table, subject_index, pattern_index, iterations) do
        value = LookupTable.get(table, subject_index, pattern_index)
        table = LookupTable.set(table, subject_index + 1, pattern_index + 1, value)
        fill_table(table, iterations)
      end
    end
  end
end
