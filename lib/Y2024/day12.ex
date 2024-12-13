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

  defp add({sr, sc}, {dr, dc}), do: {sr + dr, sc + dc}

  defp fold_edges(edges) do
    Enum.find_value(edges, fn
      {src, {dst, score}} when src !== dst ->
        # IO.inspect(edges)
        # :timer.sleep(1000)
        Enum.find_value(edges, fn
          {b_src, {b_dst, b_score}} when dst === b_src -> {src, {b_dst, max(score, b_score) + 1}}
          _ -> false
        end)
      _ -> false
    end)
    |> case do
      nil -> edges
      new -> [new | edges] |> Enum.uniq_by(&elem(&1, 0)) |> Enum.uniq_by(fn {_, {dst, _}} -> dst end) |> fold_edges()
    end
  end

  defp neighbors(data, {r, c}, letter) do
    {cells, walls} =
      for {dir, dr, dc} <- [{:north, -1, 0}, {:east, 0, 1}, {:south, 1, 0}, {:west, 0, -1}],
          nr = r + dr,
          nc = c + dc,
          reduce: {[], []} do {cells, walls} ->
            case {data.cells[{nr, nc}], dir} do
              {^letter, _} -> {[{nr, nc} | cells], walls}

              {_, :east} -> {cells, [{{r, c + 1}, {r + 1, c + 1}} | walls]}
              {_, :west} -> {cells, [{{r + 1, c}, {r, c}} | walls]}
              {_, :south} -> {cells, [{{r + 1, c + 1}, {r + 1, c}} | walls]}
              {_, :north} -> {cells, [{{r, c}, {r, c + 1}} | walls]}
            end
          end

    Enum.map(walls, fn {src, dst} -> {src, {dst, 0}} end)
    |> fold_edges()
    |> case do
      [] ->
        for {soff, doff} <- [{{0, 0}, {-1, 0}}, {{0, 1}, {0, 2}}, {{1, 1}, {2, 1}}, {{1, 0}, {1, -1}}],
            do: {add({r, c}, soff), {add({r, c}, doff), :inc}}
      n -> n
    end
    # |> tap(&IO.inspect/1)
    |> case do
      n -> {cells, n}
    end
  end

  defp combine(list) do
    (for {src, {dst, n}} <- list,
        reduce: %{} do acc ->
          Map.update(acc, src, {dst, n}, fn
            {_, :inc} when n === :inc -> nil
            {_, :inc} -> {dst, n + 1}
            {_, m} when n === :inc -> {dst, m + 1}
            a -> a
          end)
        end)
    |> Map.filter(fn {_, {_, :inc}} -> false; _ -> true end)
    |> tap(&IO.inspect/1)
  end

  defp bfs(data, nodes, letter, area \\ 0, sides \\ [], remaining)
  defp bfs(_, [], _, area, sides, remaining), do: {area, combine(sides), remaining}
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

  defp count_sides(sides), do: count_sides(Enum.find_value(sides, &elem(&1, 0)), sides, 0)
  defp count_sides(src, sides, total) do
    case Map.get(sides, src) do
      {dst, val} -> count_sides(dst, Map.put(sides, src, :seen), total + val)
      :seen ->
        case sides |> Enum.find(fn {_, :seen} -> false; _ -> true end) do
          nil -> IO.inspect(total + 1); total + 1
          {{src, dir}, _} -> count_sides({src, dir}, sides, total)
        end
    end
    # case Map.get(sides, {src, dir}) do
    #   nil -> IO.inspect("CORNER"); count_sides({src, turn(dir)}, sides, total + 1)
    #   :seen ->
    #     case sides |> Enum.find(fn {_, :seen} -> false; _ -> true end) do
    #       nil -> IO.inspect({:sides, total}); total
    #       {{src, dir}, _} -> count_sides({src, dir}, sides, total)
    #     end
    #   dst -> IO.inspect({src, dst}); count_sides({dst, dir}, Map.put(sides, {src, dir}, :seen), total)
    # end
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
