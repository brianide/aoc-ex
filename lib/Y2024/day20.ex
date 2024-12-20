defmodule AOC.Y2024.Day20 do
  @moduledoc title: "Race Condition"
  @moduledoc url: "https://adventofcode.com/2024/day/20"

  def solver, do: AOC.Scaffold.chain_solver(2024, 20, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    case AOC.Util.parse_grid(input) do
      {%{"#" => w, "S" => [s], "E" => [e]}, r, c} ->
        {%{walls: w, rows: r, cols: c}, {s, e}}
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

  def check_skips(%{walls: walls, rows: rm, cols: cm}, dists) do
    for {wr, wc} <- walls,
        wr > 0 && wr < rm - 1,
        wc > 0 && wc < cm - 1,
        sides = neighbors({wr, wc}),
        na <- sides,
        nb <- sides,
        na !== nb,
        na not in walls,
        nb not in walls,
        da = Map.get(dists, na),
        db = Map.get(dists, nb),
        saved = db - da - 2,
        # saved > 0,
        # do: {{na, nb}, saved}
        saved >= 100,
        reduce: 0, do: (acc -> acc + 1)
  end

  # def show_skips(skips, %{walls: walls, rows: rm, cols: cm}, start, finish) do
  #   Stream.map(0..(rm - 1), fn r ->
  #     Stream.map(0..(cm - 1), fn c ->
  #       cond do
  #         {r, c} === start -> "S"
  #         {r, c} === finish -> "E"
  #         {r, c} in walls -> '#'
  #         {r, c} -> '.'
  #       end
  #     end)
  #     |> Enum.join("")
  #   end)
  #   |> Enum.join("\n")
  #   |> IO.puts()
  # end

  def silver({map, {start, finish}}) do
    dists = bfs(finish, map)
    check_skips(map, dists)

    # show_skips(nil, map, start, finish)
    # |> Enum.group_by(&elem(&1, 1), fn _ -> 1 end)
    # |> Enum.map(fn {k, v} -> {k, length(v)} end)
    # |> Enum.sort(:desc)
    # |> inspect(charlists: :as_lists)
  end

  def gold(_input) do
    "Not implemented"
  end

end
