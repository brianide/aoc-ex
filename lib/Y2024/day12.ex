defmodule AOC.Y2024.Day12 do
  @moduledoc title: "Garden Groups"
  @moduledoc url: "https://adventofcode.com/2024/day/12"

  def solver, do: AOC.Scaffold.double_solver(2024, 12, &parse/1, &solve/1)

  def parse(input) do
    String.graphemes(input)
    |> Enum.reduce({%{}, [], 0, 0, 0}, fn
      "\n", {cells, heads, r, c, _} -> {cells, heads, r + 1, 0, c}
      n, {cells, heads, r, c, wd} -> {Map.put(cells, {r, c}, n), heads, r, c + 1, wd}
    end)
    |> case do {cells, heads, r, _, wd} -> %{cells: cells, heads: heads, rows: r + 1, cols: wd} end
  end

  defp neighbors(data, {r, c}, letter) do
    for {dir, dr, dc} <- [{:east, 0, 1}, {:west, 0, -1}, {:south, 1, 0}, {:north, -1, 0}],
        nr = r + dr,
        nc = c + dc,
        reduce: {[], []} do {cells, walls} ->
          case {data.cells[{nr, nc}], dir} do
            {^letter, _} -> {[{nr, nc} | cells], walls}

            {_, :east} -> {cells, [{{{r, c + 1}, :south}, {r + 1, c + 1}} | walls]}
            {_, :west} -> {cells, [{{{r + 1, c}, :north}, {r, c}} | walls]}
            {_, :south} -> {cells, [{{{r + 1, c + 1}, :west}, {r + 1, c}} | walls]}
            {_, :north} -> {cells, [{{{r, c}, :east}, {r, c + 1}} | walls]}
          end
        end
  end

  # defp foo(enum) do
  #   for {k, v} <- enum, reduce: %{}, do: (acc -> if Map.has_key?(acc, k), do: IO.inspect("Duplicate key #{inspect({k, v})}, prev: #{inspect(acc[k])}"); Map.put(acc, k, v))
  # end

  defp bfs(data, nodes, letter, area \\ 0, sides \\ [], remaining)
  defp bfs(_, [], _, area, sides, remaining), do: {area, Map.new(sides), remaining}
  defp bfs(data, nodes, letter, area, sides, remaining) do
    for n <- nodes,
        reduce: {area, sides, [], remaining} do {area, sides, next, remaining} ->
          {neigh, walls} = neighbors(data, n, letter)
          {
            area + 1,
            Stream.concat(walls, sides),
            Stream.concat(next, neigh),
            MapSet.delete(remaining, n)
          }
        end
    |> case do {area, sides, next, remaining} ->
      next = next |> Stream.filter(&MapSet.member?(remaining, &1)) |> Stream.uniq() |> Enum.to_list()
      bfs(data, next, letter, area, sides, remaining)
    end
  end

  defp turn(:north), do: :east
  defp turn(:east), do: :south
  defp turn(:south), do: :west
  defp turn(:west), do: :north

  defp count_sides(sides), do: count_sides(Enum.find_value(sides, &elem(&1, 0)), sides, 0)
  defp count_sides({src, dir}, sides, total) do
    case Map.get(sides, {src, dir}) do
      nil -> IO.inspect("CORNER"); count_sides({src, turn(dir)}, sides, total + 1)
      :seen ->
        case sides |> Enum.find(fn {_, :seen} -> false; _ -> true end) do
          nil -> IO.inspect({:sides, total}); total
          {{src, dir}, _} -> count_sides({src, dir}, sides, total)
        end
      dst -> IO.inspect({src, dst}); count_sides({dst, dir}, Map.put(sides, {src, dir}, :seen), total)
    end
  end

  defp score(data, remaining, total \\ 0, total_bulk \\ 0) do
    node = Enum.find(remaining, &(&1))
    {area, sides, remaining} = bfs(data, [node], data.cells[node], remaining)
    total = total + area * map_size(sides)
    total_bulk = total_bulk + area * count_sides(sides)
    if MapSet.size(remaining) === 0 do
      {total, total_bulk}
    else
      score(data, remaining, total, total_bulk)
    end
  end

  def solve(data), do: score(data, MapSet.new(Map.keys(data.cells)))

end
