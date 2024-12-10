defmodule AOC.Y2024.Day10 do
  @moduledoc title: "Hoof It"
  @moduledoc url: "https://adventofcode.com/2024/day/10"

  def solver, do: AOC.Scaffold.double_solver(2024, 10, &parse/1, &solve/1)

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
    for {dr, dc} <- [{0, 1}, {0, -1}, {1, 0}, {-1, 0}],
        r = r + dr,
        c = c + dc,
        r >= 0 && r < data.rows,
        c >= 0 && c < data.cols,
        do: {{r, c}, Map.fetch!(data.cells, {r, c})}
  end

  defp traverse(_, pos, 9), do: {1, MapSet.new([pos])}
  defp traverse(data, pos, alt) do
    for {{r, c}, n_alt} <- neighbors(data, pos),
        n_alt === alt + 1,
        {trails, reached} = traverse(data, {r, c}, n_alt),
        reduce: {0, MapSet.new()},
        do: ({total, merged} -> {total + trails, MapSet.union(merged, reached)})
  end

  def solve(data) do
    for head <- data.heads,
        {trails, reached} = traverse(data, head, 0),
        reduce: {0, 0},
        do: ({s, g} -> {s + MapSet.size(reached), g + trails})
  end

end
