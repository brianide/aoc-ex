defmodule AOC.Y2024.Day16 do
  @moduledoc title: "Reindeer Maze"
  @moduledoc url: "https://adventofcode.com/2024/day/16"

  def solver, do: AOC.Scaffold.chain_solver(2024, 16, &parse/1, &silver/1, &gold/1)

  alias PriorityQueue, as: PQ

  def parse(input) do
    case AOC.Util.parse_grid(input, dims: false, as_strings: false, ignore: [?#]) do
      %{?. => t, ?S => [s], ?E => [e]} ->
        {MapSet.new([s, e | t]), s, e}
    end
  end

  defp neighbors(tiles, {r, c}, visited) do
    for {dir, dr, dc} <- [{:north, -1, 0}, {:south, 1, 0}, {:east, 0, 1}, {:west, 0, -1}],
        r = r + dr,
        c = c + dc,
        {r, c} in tiles,
        {r, c} not in visited,
        do: {{r, c}, dir}
  end

  defp search(queue, finish, tiles, visited \\ MapSet.new()) do
    {{score, {pos, dir}}, queue} = PQ.pop!(queue)
    if pos === finish do
      score
    else
      visited = MapSet.put(visited, pos)
      for {n_pos, n_dir} <- neighbors(tiles, pos, visited),
          reduce: queue do queue ->
            n_score = if n_dir === dir, do: score + 1, else: score + 1001
            PQ.put(queue, n_score, {n_pos, n_dir})
          end
      |> search(finish, tiles, visited)
    end
  end

  def silver({tiles, start, finish}) do
    PQ.new()
    |> PQ.put(0, {start, :east})
    |> search(finish, tiles)
    |> inspect(charlists: :as_lists)
  end

  def gold(_input) do
    "Not implemented"
  end

end
