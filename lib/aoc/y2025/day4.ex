defmodule AOC.Y2025.Day4 do
  use AOC.Solution,
    title: "Printing Department",
    url: "https://adventofcode.com/2025/day/4",
    scheme: {:chain, &parse/1, &silver/1, &gold/2},
    complete: true,
    tags: [:grid, :visual]

  def parse(input) do
    case AOC.Util.parse_map(input, dims: false) do
      %{?@ => ps} -> MapSet.new(ps)
    end
  end

  def get_neighbors(rolls, {r, c}) do
    for i <- -1..1,
        j <- -1..1,
        i != 0 or j != 0,
        p = {r + i, c + j},
        reduce: [] do
      acc ->
        if MapSet.member?(rolls, p), do: [p | acc], else: acc
    end
  end

  @doc """
  Returns a tuple `{reached, next}`, where `reached` is a MapSet of reachable coordinates, and
  `next` is a MapSet of neighbors to the coordinates in `reached` that are not themselves members
  of `reached`.
  """
  def get_reachable(rolls, inits) do
    for pos <- inits,
        reduce: {[], []} do
      {reached, next} = acc ->
        neighbors = get_neighbors(rolls, pos)

        if length(neighbors) < 4 do
          {[pos | reached], neighbors ++ next}
        else
          acc
        end
    end
    |> case do
      {reached, next} ->
        reached = MapSet.new(reached)
        next = MapSet.new(next) |> MapSet.difference(reached)
        {reached, next}
    end
  end

  def silver(input) do
    {reached, _} = res = get_reachable(input, input)
    {MapSet.size(reached), res}
  end

  def count_culled(rolls, inits, total) do
    # Stop when inits is empty (which means nothing was culled)
    if MapSet.size(inits) > 0 do
      {reached, inits} = get_reachable(rolls, inits)
      total = total + MapSet.size(reached)
      rolls = MapSet.difference(rolls, reached)
      count_culled(rolls, inits, total)
    else
      total
    end
  end

  def gold(input, {reached, next}) do
    # First pass was performed by the silver solution, so we use its results to
    # prime the second loop
    MapSet.difference(input, reached)
    |> count_culled(next, MapSet.size(reached))
  end
end
