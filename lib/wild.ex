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

    * `:on_pattern_error` - What to do when the pattern is invalid.  The
    default is `:fail` which is simliar to case statements in Bash where an
    invalid pattern won't match the subject.  Other options are `:raise` and
    `:return` which `raise` an error or return an `{:error, error}` tuple
    respectively.

    * `:verbose` - Enable verbose mode, mainly useful when paired with
      `mode: :base`.  Defaults to false.
  """
  def match?(subject, pattern, opts) do
    case Keyword.get(opts, :mode) do
      :byte -> Byte.match?(subject, pattern, opts)
      :bash -> Bash.match?(subject, pattern, opts)
      _ -> Codepoint.match?(subject, pattern, opts)
    end
  end
end
