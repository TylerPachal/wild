defmodule Wild.Regex do

  def match?(subject, pattern, opts \\ []) do
    on_pattern_error = Keyword.get(opts, :on_pattern_error) || :fail

    case {compile_pattern(pattern), on_pattern_error} do
      {{:ok, regex}, _} ->
        Regex.match?(regex, subject)
      {{:error, _}, :fail} ->
        false
      {{:error, _} = tuple, :return} ->
        tuple
      {{:error, error_message}, :raise} ->
        raise error_message
    end
  end

  def compile_pattern(pattern) do
    IO.inspect(pattern, label: :raw)

    # Escaped
    pattern = Regex.escape(pattern)
    IO.inspect(pattern, label: :escaped)

    # Replace wildcards
    pattern =
      pattern
      |> String.replace("\\*", ".*")
      |> String.replace("\\?", ".")

    IO.inspect(pattern, label: :replaced_wildcards)

    # Replace class-related tokens
    # Note: It is valid to have an open bracket with no closing bracket, the
    # open bracket will be treated literally in that case.
    # Note: A closing bracket should be treated literally if it is the first
    # member of a class.
    pattern = Regex.replace(~r/\\\[!(.*)\\\]/U, pattern, "[^\\1]")
    IO.inspect(pattern, label: :replaced_classes1)
    pattern = Regex.replace(~r/\\\[(.*)\\\]/U, pattern, "[\\1]")
    IO.inspect(pattern, label: :replaced_classes2)
    pattern = Regex.replace(~r/\[\](.*)\\\]/, pattern, "[\\]\\1]")
    IO.inspect(pattern, label: :replaced_classes3)
    pattern = Regex.replace(~r/\[\](.*)\\\]/, pattern, "[\\]\\1]")
    pattern = String.replace(pattern, "\\-", "-")

    IO.inspect(pattern, label: :replaced_classes)

    # Anchor
    pattern = "^" <> pattern <> "$"
    IO.inspect(pattern, label: :anchored)

    # Compile and return
    Regex.compile(pattern, "s")
  end
end
