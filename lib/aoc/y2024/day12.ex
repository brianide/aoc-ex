defmodule AOC.Y2024.Day12 do
  @moduledoc title: "Garden Groups"
  @moduledoc url: "https://adventofcode.com/2024/day/12"

  def solver, do: AOC.Scaffold.double_solver(2024, 12, &parse/1, &solve/1)

  alias AOC.Util.Point
  alias AOC.Util.Direction, as: Dir

  def parse(input) do
    AOC.Util.parse_map(input, dims: false, as_strings: true)
    |> Map.new(fn {k, vs} -> {k, MapSet.new(vs)} end)
  end

  defp neighbors(tiles, pos) do
    for {dir, delta} <- [{:east, {0, 1}}, {:west, {0, -1}}, {:south, {1, 0}}, {:north, {-1, 0}}],
        npos = Point.add(pos, delta),
        npos in tiles,
        reduce: {[], []},
        do: ({points, conns} -> {[npos | points], [dir | conns]})
  end

  defp bfs(queue, seen \\ MapSet.new(), peri \\ 0, boundaries \\ [], neighbors) do
    case Enum.find(queue, &(&1)) do
      nil -> {seen, peri, MapSet.new(boundaries)}
      node ->
        seen = MapSet.put(seen, node)
        {near, conns} = neighbors.(node)
        queue = Stream.filter(near, &(&1 not in seen)) |> MapSet.new() |> MapSet.union(MapSet.delete(queue, node))

        peri = peri + 4 - length(near)
        sides = for side <- [:north, :south, :east, :west], side not in conns, do: (Dir.turn_right(side))
        boundaries = if length(near) === 4, do: boundaries, else: Enum.map(sides, &{node, &1}) ++ boundaries
        bfs(queue, seen, peri, boundaries, neighbors)
    end
  end

  defp find_islands_for_letter(tiles, letter, islands \\ []) do
    start = Enum.find(tiles, &(&1)) |> List.wrap() |> MapSet.new()
    found = bfs(start, &neighbors(tiles, &1))
    islands = [found | islands]
    tiles = MapSet.difference(tiles, elem(found, 0))
    if MapSet.size(tiles) === 0 do
      islands
    else
      find_islands_for_letter(tiles, letter, islands)
    end
  end

  defp find_islands(input) do
    for letter <- Map.keys(input),
        tiles = Map.get(input, letter) do
          find_islands_for_letter(tiles, letter)
          |> tap(&IO.inspect/1)
        end
    |> Enum.flat_map(&(&1))
  end

  defp path(pos, dir, path) do
    Enum.scan([:stay | path], {pos, dir}, fn move, {pos, dir} ->
      case move do
        :stay -> {pos, dir}
        :forward -> {Point.add(pos, Dir.offset(dir)), dir}
        :left -> {pos, Dir.turn_left(dir)}
        :right -> {pos, Dir.turn_right(dir)}
      end
    end)
    |> Enum.reverse()
  end

  defp pixels(pos, dir) do
    [{[:forward, :left, :forward], 1}, {[:forward], 0}, {[:right, :forward, :left, :forward], 2}]
    |> Enum.map(fn {moves, cost} -> {path(pos, dir, moves), cost} end)
  end

  defp trace_contour(pos, dir, tiles, sides \\ 0, seen \\ MapSet.new()) do
    IO.inspect({pos, dir})
    if {pos, dir} in seen do
      {sides, seen}
    else
      seen = MapSet.put(seen, {pos, dir})
      pixels(pos, dir)
      |> Enum.find(fn {[state | _], _} -> state in tiles end)
      |> case do
        nil ->
          trace_contour(pos, Dir.turn_right(dir), tiles, sides + 1, seen)
        {[{n_pos, n_dir} | rest], cost} ->
          seen = MapSet.union(seen, MapSet.new(rest))
          trace_contour(n_pos, n_dir, tiles, sides + cost, seen)
      end
    end
  end

  defp calc_sides(tiles) do
    if MapSet.size(tiles) === 0 do
      0
    else
      {pos, dir} = Enum.find(tiles, &(&1))
      {sides, seen} = trace_contour(pos, dir, tiles)
      tiles = MapSet.difference(tiles, seen)
      sides + calc_sides(tiles)
    end
    |> tap(&IO.inspect/1)
  end

  def solve(input) do
    for {tiles, peri, bound} <- find_islands(input),
        reduce: {0, 0} do {ts, tg} ->
          {ts + MapSet.size(tiles) * peri, tg + MapSet.size(tiles) * calc_sides(bound)}
        end
  end

end
