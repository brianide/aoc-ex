defmodule AOC.Sigils do
  def sigil_g(str, []) do
    str
    |> String.trim()
    |> AOC.Util.parse_grid(dims: false)
    |> Map.new(fn {k, [p]} -> {k, p} end)
  end
end
