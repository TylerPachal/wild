defmodule Wild do
  @moduledoc """
  Provides the interface to underlying wildcard implementations via the public
  `match/2` and `match/3` functions.
  """
  alias Wild.{Bash, Byte, Codepoint}
  require Logger

  @doc """
  Executes a unix-style wildcard pattern match on a string with a given
  pattern.  By default it tokenizes and runs on Codepoints but can also be set
  to Byte mode.

  It supports all of the usual wildcard pattern mechanisms:
    - `*` matches none or many tokens
    - `?` matches exactly one token
    - `[abc]` matches a set of tokens
    - `[a-z]` matches a range of tokens
    - `[!...]` matches anything but a set of tokens

  ## Examples

      iex> Wild.match?("foobar", "foo*")
      true

      iex> Wild.match?("foobar", "fo[a-z]bar")
      true

      iex> Wild.match?(<<9, 97, 98>>, "?ab")
      true

      iex> Wild.match?("foobar", "bar*")
      false

      iex> Wild.match?(<<16, 196, 130, 4>>, "????", mode: :byte)
      true

  The options are:

    * `:mode` - The matching mode.  This primarily affects tokenization and
      what is considered a single match for the `?` wildcard.  Options are:

      * `:codepoint` (default) - Tokenize on printable String characters
      * `:byte` - Tokenize on each byte
      * `:bash` - Using an underlying bash script.  Only for debugging

      The distinction is important for subject and patterns like the following,
      where the binary is represented by four bytes but only three codepoints:
      ```
      iex> Wild.match?(<<16, 196, 130, 4>>, "????", mode: :codepoint)
      false

      iex> Wild.match?(<<16, 196, 130, 4>>, "????", mode: :byte)
      true
      ```

      If you are dealing with user input from forms this is likely not
      something you will encounter and can keep the default value of
      `:codepoint`.

    * `:on_pattern_error` - What to do when the pattern is invalid.  The
    options are:

      * `:fail` (default) - Simliar to case statements in Bash where an
      invalid pattern won't match the subject, simply fail the match and return
      `false`
      * `:return` - Returns an `{:error, error}` tuple
      * `:raise` - Raise an error
  """
  def match?(subject, pattern, opts \\ []) do
    case Keyword.get(opts, :mode) do
      :bash -> Bash.match?(subject, pattern, opts)
      :byte -> Byte.match?(subject, pattern, opts)
      _ -> Codepoint.match?(subject, pattern, opts)
    end
  end
end
