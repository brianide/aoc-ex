defmodule AOC.Y2024.Day8 do
  @moduledoc title: "Resonant Collinearity"
  @moduledoc url: "https://adventofcode.com/2024/day/8"

  def solver, do: AOC.Scaffold.chain_solver(2024, 8, &parse/1, &solve(&1, false), &solve(&1, true))

  def parse(input) do
    String.graphemes(input)
    |> Enum.reduce({%{}, 0, 0, 0}, fn
      "\n", {ant, r, c, _} -> {ant, r + 1, 0, c}
      ".", {ant, r, c, wd} -> {ant, r, c + 1, wd}
      n, {ant, r, c, wd} -> {Map.update(ant, n, [{r, c}], &[{r, c} | &1]), r, c + 1, wd}
    end)
    |> case do {ant, r, _, wd} -> %{ants: ant, rows: r + 1, cols: wd} end
  end

  defp add({r, c}, {dr, dc}), do: {r + dr, c + dc}
  defp negate({r, c}), do: {-r, -c}
  defp difference({ar, ac}, {br, bc}), do: {br - ar, bc - ac}

  defp plot_antinodes(seen, {r, c}, d, rows, cols, multi) do
    if r < 0 || r >= rows || c < 0 || c >= cols do
      seen
    else
      seen = MapSet.put(seen, {r, c})
      if not multi, do: seen, else: plot_antinodes(seen, add({r, c}, d), d, rows, cols, multi)
    end
  end

  defp solve(scen, multi) do
    Enum.reduce(scen.ants, MapSet.new(), fn {_, ants}, seen ->
      for a <- ants,
          b <- ants,
          a !== b,
          reduce: seen do acc ->
            diff = difference(a, b)
            rev = negate(diff)
            a = if multi, do: a, else: add(a, rev)
            b = if multi, do: b, else: add(b, diff)

            acc
            |> plot_antinodes(a, rev, scen.rows, scen.cols, multi)
            |> plot_antinodes(b, diff, scen.rows, scen.cols, multi)
          end
    end)
    |> MapSet.size()
  end

end
