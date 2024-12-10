defmodule AOC.Y2024.Day10 do
  @moduledoc title: "Hoof It"
  @moduledoc url: "https://adventofcode.com/2024/day/10"

  def solver, do: AOC.Scaffold.chain_solver(2024, 10, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    String.graphemes(input)
    |> Enum.reduce({%{}, [], 0, 0, 0}, fn
      "\n", {cells, heads, r, c, _} -> {cells, heads, r + 1, 0, c}
      "0", {cells, heads, r, c, wd} -> {Map.put(cells, {r, c}, 0), [{r, c} | heads], r, c + 1, wd}
      n, {cells, heads, r, c, wd} -> {Map.put(cells, {r, c}, String.to_integer(n)), heads, r, c + 1, wd}
    end)
    |> case do {cells, heads, r, _, wd} -> %{cells: cells, heads: heads, rows: r + 1, cols: wd} end
  end

  def neighbors(data, {r, c}) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Stream.map(fn {dr, dc} -> {r + dr, c + dc} end)
    |> Stream.filter(fn {r, c} -> r >= 0 && r < data.rows && c >= 0 && c < data.rows end)
    |> Stream.map(&{&1, Map.fetch!(data.cells, &1)})
    |> Enum.to_list()
  end

  defp traverse(_, pos, 9), do: {1, MapSet.new([pos])}
  defp traverse(data, pos, alt) do
    neighbors(data, pos)
    |> Stream.filter(&(elem(&1, 1) === alt + 1))
    |> Stream.map(&elem(&1, 0))
    |> Stream.map(&traverse(data, &1, alt + 1))
    |> Enum.reduce({0, MapSet.new()}, fn {total, merged}, {n, reached} -> {total + n, MapSet.union(merged, reached)} end)
  end

  def silver(data) do
    Stream.map(data.heads, fn pos -> traverse(data, pos, 0) end)
    |> Stream.map(fn {_, reached} -> MapSet.size(reached) end)
    |> Enum.sum()
  end

  def gold(_input) do
    "Not implemented"
  end

end
