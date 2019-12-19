# Wild

Wild is a wildcard matching library that aims to mimic unix-style pattern matching functionality in Elixir.

## Installation

```elixir
def deps do
  [
    {:wild, "~> 1.0.0-rc.1"}
  ]
end
```

## Examples

```elixir
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
```

---

More information can be found in the [documentation](https://hexdocs.pm/wild/Wild.html).

