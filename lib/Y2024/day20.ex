defmodule AOC.Y2024.Day20 do
  @moduledoc title: "Race Condition"
  @moduledoc url: "https://adventofcode.com/2024/day/20"

  def solver, do: AOC.Scaffold.double_solver(2024, 20, &parse/1, &solve/1)

  def parse(input) do
    case AOC.Util.parse_grid(input, dims: false) do
      %{"#" => w, "S" => [s], "E" => [e]} -> {w, s, e}
    end
  end

  defp neighbors({r, c}) do
    for {dr, dc} <- [{0, 1}, {0, -1}, {1, 0}, {-1, 0}],
        r = r + dr,
        c = c + dc do
          {r, c}
        end
  end

  defp bfs(walls, start, goal), do: bfs([start], walls, goal, 1, %{start => 0})
  defp bfs(_, _, goal, _, dists) when is_map_key(dists, goal), do: dists
  defp bfs(queue, walls, goal, depth, dists) do
    for curr <- queue,
        pos <- neighbors(curr),
        pos not in walls,
        not is_map_key(dists, pos),
        into: %{} do {pos, depth} end
    |> case do
      ns -> bfs(Map.keys(ns), walls, goal, depth + 1, Map.merge(dists, ns))
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

  def solve({walls, start, finish}), do: bfs(walls, finish, start) |> check_skips()

end
