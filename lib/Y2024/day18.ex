defmodule AOC.Y2024.Day18 do
  @moduledoc title: "RAM Run"
  @moduledoc url: "https://adventofcode.com/2024/day/18"

  def solver, do: AOC.Scaffold.chain_solver(2024, 18, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    for [s] <- Regex.scan(~r/\d+/, input) do String.to_integer(s) end
    |> Stream.chunk_every(2)
    |> Enum.map(fn [r, c] -> {r, c} end)
  end

  @size 70

  defp neighbors({r, c}) do
    for {dr, dc} <- [{0, 1}, {0, -1}, {1, 0}, {-1, 0}],
        nr = r + dr,
        nc = c + dc,
        nr >= 0 && nr <= @size,
        nc >= 0 && nc <= @size do
          {nr, nc}
        end
  end

  defp bfs(walls), do: bfs(MapSet.new([{0, 0}]), walls, MapSet.new(), 0)
  defp bfs(queue, walls, visited, dist) do
    cond do
      MapSet.size(queue) === 0 ->
        :unreachable

      MapSet.member?(queue, {@size, @size}) ->
        dist

      :else ->
        visited = MapSet.union(visited, queue)
        queue
        |> Stream.flat_map(&neighbors/1)
        |> Stream.filter(&(&1 not in visited && &1 not in walls))
        |> MapSet.new()
        |> bfs(walls, visited, dist + 1)
    end
  end

  def silver(walls), do: Enum.take(walls, 1024) |> bfs()

  defp bin_search(l, r, _) when l === r, do: l
  defp bin_search(l, r, pred) do
    m = ceil((l + r) / 2)
    if not pred.(m) do
      bin_search(l, m - 1, pred)
    else
      bin_search(m, r, pred)
    end
  end

  def gold(walls) do
    bin_search(@size, length(walls) - 1, &(Enum.take(walls, &1) |> bfs() !== :unreachable))
    |> then(&Enum.at(walls, &1))
    |> case do
      {r, c} -> "#{r},#{c}"
    end
  end

end
