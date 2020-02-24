defmodule Wild do
  @moduledoc """
  Provides the interface to underlying wildcard implementations.

  The `match?/3` and `valid_pattern?/1` functions support all of the usual
  wildcard pattern mechanisms:
    - `*` matches none or many tokens
    - `?` matches exactly one token
    - `[abc]` matches a set of tokens
    - `[a-z]` matches a range of tokens
    - `[!...]` matches anything but a set of tokens
  """
  alias Wild.{Bash, Engine, Validator}
  require Logger

  @doc """
  Executes a unix-style wildcard blob pattern match on a binary with a given
  pattern.  By default it tokenizes and runs on `codepoints` but can also be set
  to `byte` mode.

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
      where the binary is represented by two bytes but only one codepoint:
      ```
      iex> Wild.match?("ā", "?", mode: :codepoint)
      true

      iex> Wild.match?("ā", "?", mode: :byte)
      false
      ```

      If we do an example tokenization of our `"ā"` subject we can see that
      depending on how you treat the binary you can produce different amounts
      tokens:
      ```
      iex> String.codepoints("ā")
      ["ā"]

      iex> :binary.bin_to_list("ā")
      [196, 129]
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
  @spec match?(binary(), binary()) :: boolean()
  @spec match?(binary(), binary(), keyword()) :: boolean() | {:error, String.t()}
  def match?(subject, pattern, opts \\ []) do
    opts = Keyword.put_new(opts, :mode, :codepoint)
    case Keyword.get(opts, :mode) do
      :bash -> Bash.match?(subject, pattern, opts)
      _ -> Engine.match?(subject, pattern, opts)
    end
  end

  @doc """
  Checks if the given pattern is a valid unix-style wildcard pattern.  The most
  common invalid patterns arise because of invalid escape sequences.  Mode can
  be either `:byte` or `:codepoint` (default).

  ## Examples

      iex> Wild.valid_pattern?("fo[a-z]b?r")
      true

      iex> Wild.valid_pattern?(<<?\\\\, ?a>>)
      false

      iex> Wild.valid_pattern?("hello", :codepoint)
      true

      iex> Wild.valid_pattern?(123)
      false
  """
  @spec valid_pattern?(binary()) :: boolean()
  @spec valid_pattern?(binary(), :byte | :codepoint) :: boolean()
  def valid_pattern?(pattern, mode \\ :codepoint)
  def valid_pattern?(pattern, mode) when is_binary(pattern) do
    Validator.valid?(pattern, mode)
  end
  def valid_pattern?(_, _) do
    false
  end
end
