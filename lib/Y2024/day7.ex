defmodule AOC.Y2024.Day7 do
  @moduledoc title: "Bridge Repair"
  @moduledoc url: "https://adventofcode.com/2024/day/7"

  def solver, do: AOC.Scaffold.chain_solver(2024, 7, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    String.split(input, "\n")
    |> Enum.map(fn s -> Regex.scan(~r/\d+/, s) |> Enum.map(&(List.first(&1) |> String.to_integer())) |> then(fn [h | r] -> {h, r} end) end)
  end

  def search(targ, terms), do: search(targ, 0, terms)
  def search(targ, total, []) when total == targ, do: 1
  def search(targ, total, _) when total > targ, do: 0
  def search(_, _, []), do: 0
  def search(targ, total, [h | rest]) do
    search(targ, total + h, rest) + search(targ, total * h, rest)
  end

  def silver(input) do
    input
    |> Stream.filter(fn {targ, terms} -> search(targ, terms) > 0 end)
    |> Stream.map(fn {v, _} -> v end)
    |> Enum.sum()
    |> inspect(charlists: :as_lists)
  end

  def gold(_input) do
    "Not implemented"
  end

end
