defmodule AOC.Y2025.Day4 do
  use AOC.Solution,
    title: "Printing Department",
    url: "https://adventofcode.com/2025/day/4",
    scheme: {:chain, &parse/1, &silver/1, &gold/2},
    complete: false

  def parse(input) do
    case AOC.Util.parse_map(input, dims: false) do
      %{?@ => ps} -> MapSet.new(ps)
    end
  end

  def count_neighbors(rolls, {r, c}) do
    for i <- -1..1,
        j <- -1..1,
        i != 0 or j != 0,
        reduce: 0 do acc ->
          if MapSet.member?(rolls, {r + i, c + j}) do
            acc + 1
          else
            acc
          end
        end
  end

  def get_reachable_rolls(rolls) do
    for pos <- rolls,
        reduce: [] do acc ->
          if count_neighbors(rolls, pos) < 4 do
            [pos | acc]
          else
            acc
          end
        end
    |> MapSet.new()
  end

  def silver(input) do
    reached = get_reachable_rolls(input)
    {MapSet.size(reached), reached}
  end

  def cull_reachable(rolls, reached, total \\ 0) do
    if MapSet.size(reached) > 0 do
      rolls = MapSet.difference(rolls, reached)
      total = total + MapSet.size(reached)
      reached = get_reachable_rolls(rolls)
      cull_reachable(rolls, reached, total)
    else
      total
    end
  end

  def gold(input, reached) do
    cull_reachable(input, reached)
  end

end
