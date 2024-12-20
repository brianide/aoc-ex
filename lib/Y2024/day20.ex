defmodule AOC.Y2024.Day20 do
  @moduledoc title: "Race Condition"
  @moduledoc url: "https://adventofcode.com/2024/day/20"

  def solver, do: AOC.Scaffold.double_solver(2024, 20, &parse/1, &solve/1)

  def parse(input) do
    case AOC.Util.parse_grid(input) do
      {%{"#" => w, "E" => [e]}, r, c} ->
        {%{walls: w, rows: r, cols: c}, e}
    end
  end

  defp neighbors({r, c}) do
    for {dr, dc} <- [{0, 1}, {0, -1}, {1, 0}, {-1, 0}],
        r = r + dr,
        c = c + dc do
          {r, c}
        end
  end

  defp bfs(start, map), do: bfs([start], map, 1, %{start => 0})
  defp bfs([], _, _, dists), do: dists
  defp bfs(queue, map, depth, dists) do
    for curr <- queue,
        pos <- neighbors(curr),
        pos not in map.walls,
        not is_map_key(dists, pos),
        into: %{} do {pos, depth} end
    |> case do
      ns -> bfs(Map.keys(ns), map, depth + 1, Map.merge(dists, ns))
    end
  end

  defp manhattan_dist({ra, ca}, {rb, cb}), do: abs(rb - ra) + abs(cb - ca)

  @threshold 100
  defp check_skips(dists) do
    Map.to_list(dists)
    |> AOC.Util.all_pairs()
    |> Stream.map(fn {{pa, da}, {pb, db}} ->
      dist = manhattan_dist(pa, pb)
      cond do
        abs(db - da) - dist < @threshold -> {0, 0}
        dist === 2 -> {1, 1}
        dist <= 20 -> {0, 1}
        :else -> {0, 0}
      end
    end)
    |> Enum.reduce({0, 0}, fn
      {s, g}, {ts, tg} -> {ts + s, tg + g}
    end)
  end

  def solve({map, finish}), do: bfs(finish, map) |> check_skips()

end