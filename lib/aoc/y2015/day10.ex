defmodule AOC.Y2015.Day10 do

  use AOC.Solution,
    title: "Elves Look, Elves Say",
    url: "https://adventofcode.com/2015/day/10",
    scheme: {:shared, &parse/1, &loop(&1, 40), &loop(&1, 50)},
    complete: false

  def parse(input), do: String.split(input, "", trim: true)

  def loop(input, 0), do: length(input)

  def loop(input, steps) do
    for d <- input, reduce: [] do
      [{n, ^d} | rest] -> [{n + 1, d} | rest]
      rest -> [{1, d} | rest]
    end
    |> Enum.reduce([], fn {c, d}, acc -> ["#{c}", d | acc] end)
    |> loop(steps - 1)
  end

end
