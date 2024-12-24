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
        # sides = Enum.filter([:north, :south, :east, :west], &(&1 not in conns))
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
        end
    |> Enum.flat_map(&(&1))
  end

  defp pixels(pos, dir) do
    case dir do
      :north -> for c <- -1..1, do: {-1, c}
      :south -> for c <- 1..-1, do: {1, c}
      :east -> for r <- -1..1, do: {r, 1}
      :west -> for r <- 1..-1, do: {r, -1}
    end
    |> Stream.map(&Point.add(&1, pos))
    |> Stream.zip([{Dir.turn_left(dir), 1}, {dir, 0}, {Dir.turn_right(dir), 3}])
  end

  defp trace_contour(pos, dir, tiles, sides \\ 0, seen \\ MapSet.new()) do
    if {pos, dir} in seen do
      {sides, seen}
    else
      seen = MapSet.put(seen, {pos, dir})
      pixels(pos, dir)
      |> Enum.find(fn {p, _} -> is_map_key(tiles, p) end)
      |> case do
        nil ->
          trace_contour(pos, Dir.turn_right(dir), tiles, sides + 1, seen)
        {n_pos, {n_dir, cost}} ->
          trace_contour(n_pos, n_dir, tiles, sides + cost, seen)
      end
    end
  end

  defp calc_sides(tiles) do
    IO.inspect(tiles)
    {pos, dir} = Enum.find(tiles, &(&1))
    {sides, seen} = trace_contour(pos, dir, tiles)
    tiles = Map.drop(tiles, Enum.map(seen, &elem(&1, 0)))
    sides + calc_sides(tiles)
  end

  def solve(input) do
    for {tiles, peri, bound} <- find_islands(input),
        reduce: {0, 0} do {ts, tg} ->
          {ts + MapSet.size(tiles) * peri, tg + MapSet.size(tiles) * calc_sides(bound)}
        end
  end

end
