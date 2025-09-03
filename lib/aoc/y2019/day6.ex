defmodule AOC.Y2019.Day6 do
  use AOC.Solution,
    title: "Universal Orbit Map",
    url: "https://adventofcode.com/2019/day/6",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: true

  require AOC.Read

  def parse(input) do
    for([a, b] <- Regex.scan(~r/(\w+)\)(\w+)/, input, capture: :all_but_first), do: {a, b})
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  def dfs(curr, map, depth \\ 0) do
    case map[curr] do
      nil -> depth
      subs -> depth + (Stream.map(subs, &dfs(&1, map, depth + 1)) |> Enum.sum())
    end
  end

  def silver(input) do
    vals = Enum.flat_map(input, fn {_, v} -> v end) |> MapSet.new()
    root = Map.keys(input) |> Enum.find(&(&1 not in vals))
    dfs(root, input)
  end

  def bfs(queue, graph, depth \\ 0, seen \\ MapSet.new()) do
    queue =
      for node <- queue,
          neigh <- Stream.filter(graph[node], &(&1 not in seen)),
          into: MapSet.new() do
        neigh
      end

    if "SAN" in queue do
      depth - 1
    else
      seen = for n <- queue, into: seen, do: n
      bfs(queue, graph, depth + 1, seen)
    end
  end

  def gold(input) do
    graph =
      for {k, vs} <- input,
          v <- vs,
          reduce: input do
        acc ->
          update_in(acc, [Access.key(v, [])], &[k | &1])
      end

    bfs(["YOU"], graph)
  end
end
