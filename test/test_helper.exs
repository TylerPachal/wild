ExUnit.start()

defmodule Generators do
  use PropCheck

  @wildcards ["?", "*"]
  @special_characters ["[", "]"] ++ @wildcards

  # Future TODO: Support these custom ranges
  # @special_ranges ["[:alnum:]", "[:space:]", "[:digit:]"]

  def byte_input_and_pattern() do
    let input <- input() do
      let pattern <- pattern(input) do
        {input, pattern}
      end
    end
  end

  def codepoint_input_and_pattern() do
    such_that(
      {i, p} <- byte_input_and_pattern(),
      when: String.length(i) == byte_size(i) && String.length(p) == byte_size(p)
    )
  end

  def input() do
    frequency([
      {9, text()},
      {1, string()}
    ])
  end

  def pattern(input) do
    frequency([
      {1, pattern_with_wildcards(input)},
      {1, random_pattern()}
    ])
  end

  # These patterns will be pretty liberal
  def random_pattern() do
    let value <- list(frequency([
      {60, range(?a, ?z)},              # Letters
      {20, random_class()},
      {10, ?\s},                        # Whitespace
      {5, oneof(@special_characters)},  # Special wildcard characters
      {1, ?\n},                         # Linebreaks
      {1, oneof([?., ?-, ?!, ??, ?,])}, # Punctuation
      {1, range(?0, ?9)}                # Numbers
    ])) do
      :binary.list_to_bin(value)
    end
  end

  # Take the input and replace some of the characters with wildcards
  def pattern_with_wildcards(input) do
    replaced =
      input
      |> String.codepoints()
      |> Enum.map(fn char ->
        if Enum.random(0..9) >= 8 do
          Enum.random(["?", "*", "[!abc]"])
        else
          char
        end
      end)

    :binary.list_to_bin(replaced)
  end

  # Generating random binaries are great but for now I am going to constrain
  # them to being valid strings.  I am doing this because I cannot write my
  # pattern_with_wildcards function properly to deal with binaries and
  # strings.
  # Also adding a check for the null character because that is not supported
  # by glob matching
  def string() do
    such_that(b <- binary(), when: :binary.match(b, <<0>>) == :nomatch)
  end
  def string(length) do
    such_that(b <- binary(length), when: :binary.match(b, <<0>>) == :nomatch)
  end

  def text() do
    let value <- list(frequency([
      {80, range(?a, ?z)},              # Letters
      {10, ?\s},                        # Whitespace
      {5, oneof(@special_characters)},  # Special wildcard characters
      {1, ?\n},                         # Linebreaks
      {1, oneof([?., ?-, ?!, ??, ?,])}, # Punctuation
      {1, range(?0, ?9)}                # Numbers
    ])) do
      :binary.list_to_bin(value)
    end
  end

  # The distribution here should be roughly the same as text so that we
  # will actually get maches
  def random_class() do
    let value <- list(frequency([
      {80, range(?a, ?z)},              # Letters
      # {20, oneof(@special_ranges)},     # Special ranges
      {20, ?-},                         # Dash to produce ranges
      {5, oneof(@special_characters)},  # Special wildcard characters
      {1, ?\s},                         # Whitespace
      {1, ?\n},                         # Linebreaks
      {1, range(?0, ?9)}                # Numbers
    ])) do
      let negation <- frequency([
        {4, ""},
        {1, "!"}
      ]) do
        "[" <> negation <> :binary.list_to_bin(value) <> "]"
      end
    end
  end
end
