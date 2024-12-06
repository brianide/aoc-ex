defmodule AOC.Y2024.Day6 do
  @moduledoc title: "Guard Gallivant"
  @moduledoc url: "https://adventofcode.com/2024/day/6"

  def solver, do: AOC.Scaffold.chain_solver(2024, 6, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    {obs, rows, cols, init} =
      String.graphemes(input)
      |> Enum.reduce({MapSet.new(), 0, 0, 0, {0, 0}}, fn
        "\n", {obs, r, c, _, st} -> {obs, r + 1, 0, c, st}
        "^", {obs, r, c, wd, _} -> {obs, r, c + 1, wd, {r, c}}
        "#", {obs, r, c, wd, st} -> {MapSet.put(obs, {r, c}), r, c + 1, wd, st}
        ".", {obs, r, c, wd, st} -> {obs, r, c + 1, wd, st}
      end)
      |> then(fn {obs, r, _, wd, st} -> {obs, r + 1, wd, st} end)

    %{
      rows: rows,
      cols: cols,
      init: init,
      by_row: Enum.group_by(obs, &elem(&1, 0), &elem(&1, 1)) |> Map.new(fn {k, v} -> {k, Enum.sort(v, :desc)} end),
      by_col: Enum.group_by(obs, &elem(&1, 1), &elem(&1, 0)) |> Map.new(fn {k, v} -> {k, Enum.sort(v, :desc)} end)
    }
  end

  defp turn(:north), do: :east
  defp turn(:east), do: :south
  defp turn(:south), do: :west
  defp turn(:west), do: :north

  defp neighbors(nil, _), do: {nil, nil}
  defp neighbors(list, n), do: neighbors(list, n, nil)
  defp neighbors([d | _], n, prev) when d < n, do: {prev, d}
  defp neighbors([d | rest], n, _), do: neighbors(rest, n, d)
  defp neighbors([], _, prev), do: {prev, nil}

  defp hitscan(scen, {r, c}, dir) do
    case dir do
      :north -> {{neighbors(scen.by_col[c], r) |> elem(1), c}, {1, 0}}
      :south -> {{neighbors(scen.by_col[c], r) |> elem(0), c}, {-1, 0}}
      :west -> {{r, neighbors(scen.by_row[r], c) |> elem(1)}, {0, 1}}
      :east -> {{r, neighbors(scen.by_row[r], c) |> elem(0)}, {0, -1}}
    end
    |> case do
      {{r, nil}, _} -> {:out, case dir do :west -> {r, 0}; :east -> {r, scen.rows - 1} end}
      {{nil, c}, _} -> {:out, case dir do :north -> {0, c}; :south -> {scen.rows - 1, c} end}
      {{r, c}, {dr, dc}} -> {:hit, {r + dr, c + dc}}
    end
  end

  defp points_between({ra, ca}, {rb, cb}, seen) do
    for r <- ra..rb, c <- ca..cb, reduce: seen, do: (seen -> MapSet.put(seen, {r, c}))
  end

  defp trace(scen), do: trace(MapSet.new(), scen, scen.init, :north)
  defp trace(seen, scen, p, dir) do
    case hitscan(scen, p, dir) do
      {:out, h} -> points_between(p, h, seen)
      {:hit, h} -> points_between(p, h, seen) |> trace(scen, h, turn(dir))
    end
  end

  def silver(scen), do: trace(scen) |> MapSet.size()

  defp add_obstacle(scen, {r, c}) do
    br = Map.update(scen.by_row, r, [c], fn cs -> Enum.sort([c | cs], :desc) end)
    bc = Map.update(scen.by_col, c, [r], fn rs -> Enum.sort([r | rs], :desc) end)
    %{scen | by_row: br, by_col: bc}
  end

  defp check_loop(scen), do: check_loop(scen, scen.init, :north, MapSet.new())
  defp check_loop(scen, p, dir, seen) do
    if MapSet.member?(seen, {p, dir}) do
      true
    else
      case hitscan(scen, p, dir) do
        {:out, _} -> false
        {:hit, h} ->
          seen = MapSet.put(seen, {p, dir})
          check_loop(scen, h, turn(dir), seen)
      end
    end
  end

  def gold(scen), do: Enum.count(trace(scen), fn p -> add_obstacle(scen, p) |> check_loop() end)

end
