defmodule AOC.Y2024.Day8 do
  @moduledoc title: "Resonant Collinearity"
  @moduledoc url: "https://adventofcode.com/2024/day/8"

  def solver, do: AOC.Scaffold.chain_solver(2024, 8, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    String.graphemes(input)
    |> Enum.reduce({%{}, 0, 0, 0}, fn
      "\n", {ant, r, c, _} -> {ant, r + 1, 0, c}
      ".", {ant, r, c, wd} -> {ant, r, c + 1, wd}
      n, {ant, r, c, wd} -> {Map.update(ant, n, [{r, c}], &[{r, c} | &1]), r, c + 1, wd}
    end)
    |> case do {ant, r, _, wd} -> %{cells: ant, rows: r + 1, cols: wd} end
  end

  def difference({ar, ac}, {br, bc}), do: {br - ar, bc - ac}
  def add({r, c}, {dr, dc}), do: {r + dr, c + dc}
  def negate({r, c}), do: {-r, -c}

  def find_antinodes(ants) do
    for a <- ants,
        b <- ants,
        a !== b,
        reduce: MapSet.new() do acc ->
          diff = difference(a, b)

          acc
          |> MapSet.put(add(a, negate(diff)))
          |> MapSet.put(add(b, diff))
        end
  end

  def silver(scen) do
    Stream.flat_map(scen.cells, fn {_, ants} -> find_antinodes(ants) end)
    |> MapSet.new()
    |> Enum.count(fn {r, c} -> r >= 0 && r < scen.rows && c >= 0 && c < scen.cols end)
    |> inspect(charlists: :as_lists)
  end

  def gold(_scen) do
    "Not implemented"
  end

end
