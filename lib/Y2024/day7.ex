defmodule AOC.Y2024.Day7 do
  @moduledoc title: "Bridge Repair"
  @moduledoc url: "https://adventofcode.com/2024/day/7"

  def solver, do: AOC.Scaffold.chain_solver(2024, 7, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    String.split(input, "\n")
    |> Enum.map(fn s -> Regex.scan(~r/\d+/, s) |> Enum.map(&(List.first(&1) |> String.to_integer())) |> then(fn [h | r] -> {h, r} end) end)
  end

  def concat(a, b), do: String.to_integer("#{a}#{b}")

  def search(targ, terms, do_cat), do: search(targ, 0, terms, do_cat)
  def search(targ, total, [], _) when total == targ, do: 1
  def search(targ, total, _, _) when total > targ, do: 0
  def search(_, _, [], _), do: 0
  def search(targ, total, [h | rest], do_cat) do
    search(targ, total + h, rest, do_cat) + search(targ, total * h, rest, do_cat) + (if do_cat, do: search(targ, concat(total, h), rest, do_cat), else: 0)
  end

  def solve(input, do_cat) do
    input
    |> Stream.filter(fn {targ, terms} -> search(targ, terms, do_cat) > 0 end)
    |> Stream.map(fn {v, _} -> v end)
    |> Enum.sum()
  end

  def silver(input), do: solve(input, false)
  def gold(input), do: solve(input, true)

end
