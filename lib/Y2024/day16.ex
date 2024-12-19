defmodule AOC.Y2024.Day16 do
  @moduledoc title: "Reindeer Maze"
  @moduledoc url: "https://adventofcode.com/2024/day/16"

  alias PriorityQueue, as: PQ

  def solver, do: AOC.Scaffold.chain_solver(2024, 16, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    case AOC.Util.parse_grid(input, dims: false) do
      %{"#" => walls, "S" => [s], "E" => [e]} -> {walls, s, e}
    end
  end

  defp neighbors({r, c}) do
    for {dir, dr, dc} <- [{:north, -1, 0}, {:south, 1, 0}, {:east, 0, 1}, {:west, 0, -1}],
        r = r + dr,
        c = c + dc,
        do: {{r, c}, dir}
  end

  defp turn_cost(dir, n_dir) do
    case {dir, n_dir} do
      {d, n} when d === n -> 0
      tp when tp in [{:north, :east}, {:east, :south}, {:south, :west}, {:west, :north}] -> 1000
      tp when tp in [{:north, :west}, {:west, :south}, {:south, :east}, {:east, :north}] -> 1000
      tp when tp in [{:north, :south}, {:south, :north}, {:east, :west}, {:west, :east}] -> 2000
    end
  end

  defp search(queue, finish, walls, visited \\ MapSet.new()) do
    {{score, {pos, dir}}, queue} = PQ.pop(queue)
    if pos === finish do
      score
    else
      visited = MapSet.put(visited, pos)
      for {n_pos, n_dir} <- neighbors(pos),
          n_pos not in walls,
          n_pos not in visited,
          reduce: queue do queue ->
            score = score + 1 + turn_cost(dir, n_dir)
            PQ.put(queue, score, {n_pos, n_dir})
          end
      |> search(finish, walls, visited)
    end
  end

  def silver({walls, start, finish}) do
    PQ.new()
    |> PQ.put(0, {start, :east})
    |> search(finish, walls)
    |> inspect(charlists: :as_lists)
  end

  def dfs({pos, _}, _, finish, _, seen) when pos === finish, do: seen
  def dfs(_, _, _, n, _) when n < 0, do: nil
  def dfs({pos, dir}, walls, finish, ttl, seen) do
    seen = MapSet.put(seen, pos)
    for {n_pos, n_dir} <- neighbors(pos),
        n_pos not in walls,
        n_pos not in seen,
        reduce: MapSet.new() do acc ->
          case dfs({n_pos, n_dir}, walls, finish, ttl - turn_cost(dir, n_dir) - 1, seen) do
            nil -> acc
            n -> MapSet.union(acc, n)
          end
        end
  end

  def gold({walls, start, finish}) do
    dfs({start, :east}, walls, finish, 98520, MapSet.new())
    |> MapSet.size()
    |> then(&(&1 + 1))
    |> inspect()
  end

end
