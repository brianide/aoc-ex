defmodule AOC.Y2024.Day23 do
  @moduledoc title: "LAN Party"
  @moduledoc url: "https://adventofcode.com/2024/day/23"

  def solver, do: AOC.Scaffold.chain_solver(2024, 23, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    for [_, a, b] <- Regex.scan(~r/^([a-z]{2})-([a-z]{2})$/m, input),
        reduce: %{} do acc ->
          acc
          |> Map.update(a, [b], &[b | &1])
          |> Map.update(b, [a], &[a | &1])
        end
  end

  def silver(input) do
    for {a, connected} <- input,
        String.starts_with?(a, "t"),
        {b, c} <- AOC.Util.all_pairs(connected),
        c in Map.get(input, b) do
          Enum.sort([a, b, c])
        end
    |> Enum.sort()
    |> Enum.uniq()
    |> length()
    |> inspect()
  end

  def gold(_input) do
    "Not implemented"
  end

end
