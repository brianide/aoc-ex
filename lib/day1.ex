defmodule AOC.Day1 do
  @behaviour AOC.Scaffold.Solution
  def solution_info, do: {2024, 1, "Historian Hysteria"}

  use AOC.Scaffold.ChainSolver

  def parse(input) do
    Regex.scan(~r/\d+/, input)
    |> Enum.map(fn a -> List.first(a) |> String.to_integer() end)
    |> then(&parse([], [], &1))
  end
  def parse(a, b, [ha, hb | rest]), do: parse([ha | a], [hb | b], rest)
  def parse(a, b, []), do: {a, b}

  def silver({a, b}) do
    a = Enum.sort(a)
    b = Enum.sort(b)

    Enum.zip(a, b)
    |> Enum.map(fn {a, b} -> abs(b - a) end)
    |> Enum.sum()
  end

  def gold({a, b}) do
    keys = Enum.concat(a, b) |> Enum.uniq()
    a = Enum.frequencies(a)
    b = Enum.frequencies(b)

    keys
    |> Enum.map(fn k -> Map.get(a, k, 0) * Map.get(b, k, 0) * k end)
    |> Enum.sum()
  end
end
