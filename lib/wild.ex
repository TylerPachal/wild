defmodule Wild do
  alias Wild.{Bash, Byte, Codepoint}
  require Logger

  @doc """
  Executes a unix-style WildCard match on a string with a given pattern.  By
  default it runs on Codepoints but can also be set to Binary mode.

  ## Examples

      iex> Wild.match?("foobar", "foo*")
      true

      iex> Wild.match?("foobar", "fo[a-z]bar")
      true

      iex> Wild.match?("foobar", "bar*")
      false

      iex> Wild.match?("abc" TODO TODO TODO, mode: :binary)

  The options are:

    * `:mode` - The matching mode.  This primarily affects tokenization and
      what is considered a single match for the ? wildcard.  Options are
      `:codepoint` (default), `:byte`, and `:bash`.

    * `:verbose` - Enable verbose mode, mainly useful when paired with
      `mode: :base`.Defaults to false.
  """
  def match?(subject, pattern, opts \\ [])
  def match?("", "", _opts) do
    # Empty pattern can only match empty subject
    true
  end
  def match?(_subject, "", _opts) do
    # Empty pattern can only match empty subject
    false
  end
  def match?(subject, pattern, opts) do
    case Keyword.get(opts, :mode) do
      :byte -> Byte.match?(subject, pattern, opts)
      :bash -> Bash.match?(subject, pattern, opts)
      _ -> Codepoint.match?(subject, pattern, opts)
    end
  end
end
