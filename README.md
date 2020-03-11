# Wild

![Build Status](https://github.com/TylerPachal/wild/workflows/Elixir%20CI/badge.svg)
![Hex.pm version](https://img.shields.io/hexpm/v/wild.svg)

Wild is a wildcard matching library that implements unix-style blob pattern
matching functionality for Elixir binaries (without actually interacting with
the filesystem itself).  It works on all binary input and defaults to working
with codepoint representations of binaries, but other modes are also available.

## Installation

Add the `:wild` dependency to your `mix.exs` file:

```elixir
def deps do
  [
    {:wild, "~> 1.0.0"}
  ]
end
```

## Example Usage

```elixir
# Simple match
iex> Wild.match?("foobar", "foo*")
true

# Simple non-match
iex> Wild.match?("foobar", "bar*")
false

# Classes are supported
iex> Wild.match?("foobar", "fo[a-z]bar")
true

# Non-printable binaries can be matched in byte mode
iex> Wild.match?(<<16, 196, 130, 4>>, "????", mode: :byte)
true

# Check validity of pattern
iex> Wild.valid_pattern?("fo[a-z]b?r")
true
```
