defmodule AOC.Y2024.Day12 do
  @moduledoc title: "Garden Groups"
  @moduledoc url: "https://adventofcode.com/2024/day/12"

  def solver, do: AOC.Scaffold.chain_solver(2024, 12, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    String.graphemes(input)
    |> Enum.reduce({%{}, [], 0, 0, 0}, fn
      "\n", {cells, heads, r, c, _} -> {cells, heads, r + 1, 0, c}
      "0", {cells, heads, r, c, wd} -> {Map.put(cells, {r, c}, 0), [{r, c} | heads], r, c + 1, wd}
      n, {cells, heads, r, c, wd} -> {Map.put(cells, {r, c}, n), heads, r, c + 1, wd}
    end)
    |> case do {cells, heads, r, _, wd} -> %{cells: cells, heads: heads, rows: r + 1, cols: wd} end
  end

  def neighbors(data, {r, c}, letter) do
    for {dr, dc} <- [{0, 1}, {0, -1}, {1, 0}, {-1, 0}],
        r = r + dr,
        c = c + dc,
        r >= 0 && r < data.rows,
        c >= 0 && c < data.cols,
        data.cells[{r, c}] === letter,
        do: {r, c}
  end

  def bfs(data, node, remaining), do: bfs(data, [node], data.cells[node], 0, 0, remaining)
  def bfs(_, [], _, area, peri, remaining), do: {area, peri, remaining}
  def bfs(data, nodes, letter, area, peri, remaining) do
    {area, peri, next, remaining} =
      for n <- nodes,
          reduce: {area, peri, [], remaining} do {area, peri, next, remaining} ->
            remaining = MapSet.delete(remaining, n)
            neigh = neighbors(data, n, letter)
            area = area + 1
            peri = peri + 4 - length(neigh)
            next = Stream.concat(next, neigh)
            {area, peri, next, remaining}
          end
    next = next |> Stream.filter(&MapSet.member?(remaining, &1)) |> Stream.uniq() |> Enum.to_list()
    bfs(data, next, letter, area, peri, remaining)
  end

  def score(data, remaining, total) do
    node = remaining |> MapSet.to_list() |> List.first()
    {area, peri, remaining} = bfs(data, node, remaining)
    total = total + area * peri
    if MapSet.size(remaining) === 0, do: total, else: score(data, remaining, total)
  end

  def silver(data), do: score(data, MapSet.new(Map.keys(data.cells)), 0)

  def gold(_input) do
    "Not implemented"
  end

end
