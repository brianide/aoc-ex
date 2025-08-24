defmodule AOC.Y2024.Day23 do
  @moduledoc title: "LAN Party"
  @moduledoc url: "https://adventofcode.com/2024/day/23"

  use AOC.Solvers.Chain, [2024, 23, &parse/1, &silver/1, &gold/1]

  def parse(input) do
    for [_, a, b] <- Regex.scan(~r/^([a-z]{2})-([a-z]{2})$/m, input),
        reduce: %{} do acc ->
          acc
          |> Map.update(a, [b], &[b | &1])
          |> Map.update(b, [a], &[a | &1])
        end
    |> Map.new(fn {k, vs} -> {k, MapSet.new(vs)} end)
  end

  def silver(input) do
    for {a, connected} <- input,
        String.starts_with?(a, "t"),
        {b, c} <- AOC.Util.all_pairs(connected),
        c in Map.get(input, b) do
          Enum.sort([a, b, c])
        end
    |> Enum.sort()
    |> Enum.dedup()
    |> length()
  end

  defp bron_kerobisch(r \\ MapSet.new(), p, x \\ MapSet.new(), neighbors) do
    if MapSet.size(p) === 0 && MapSet.size(x) === 0 do
      [r]
    else
      Enum.flat_map_reduce(p, {p, x}, fn v, {p, x} ->
        nv = neighbors.(v)
        res = bron_kerobisch(MapSet.put(r, v), MapSet.intersection(p, nv), MapSet.intersection(x, nv), neighbors)
        {res, {MapSet.delete(p, v), MapSet.put(x, v)}}
      end)
      |> case do {rs, _} -> rs end
    end
  end

  def gold(input) do
    Map.keys(input)
    |> MapSet.new()
    |> bron_kerobisch(&Map.get(input, &1))
    |> Enum.max_by(&MapSet.size/1)
    |> Enum.sort()
    |> Enum.join(",")
  end

end
