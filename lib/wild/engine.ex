defmodule Wild.Engine do
  @moduledoc false

  def match?(subject, pattern, opts)

  # Shortcut for the empty-string pattern, which can only match itself
  def match?("", "", _opts), do: true
  def match?(_, "", _opts), do: false

  def match?(subject, pattern, opts) do
    mode = Keyword.fetch!(opts, :mode)
    on_pattern_error = Keyword.get(opts, :on_pattern_error) || :fail

    case {compile_pattern(pattern, mode), on_pattern_error} do
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

  # Public for testing
  def compile_pattern(pattern, mode) do
    # Escaped
    pattern = Regex.escape(pattern)

    # Replace class-related tokens
    # Note: It is valid to have an open bracket with no closing bracket, the
    # open bracket will be treated literally in that case.
    # Note: A closing bracket should be treated literally if it is the first
    # member of a class.
    pattern =
      Regex.replace(~r/\\\[(!?.+)\\\]/Us, pattern, fn
        _whole_match, "!" <> rest ->
          "[^" <> rest <> "]"
        _whole_match, rest ->
          "[" <> rest <> "]"
      end)

    # Replace escape tokens
    pattern =
      pattern
      |> String.replace("\\*", ".*")
      |> String.replace("\\?", ".")
      |> String.replace("\\\n", "\n")

    # Replace escape tokens continued.
    # A double backslash with a single backslash unless the backslash is
    # followed by one of the 1-8 bytes.
    pattern =
      Regex.replace(~r/\\\\(?!\x01|\x02|\x03|\x04|\x05|\x06|\x07|\x08)/, pattern, "\\")

    # Only replace dashes that are between two characters.  The characters
    # _should_ be in asccending order.
    pattern =
      Regex.replace(~r/\\-(?!\\-)/, pattern, "-")

    # Anchor
    pattern = "^" <> pattern <> "$"

    modifiers =
      case mode do
        :codepoint -> "su"
        :byte -> "s"
      end

    # Compile and return
    Regex.compile(pattern, modifiers)
  end
end
