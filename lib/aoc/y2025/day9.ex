defmodule AOC.Y2025.Day9 do
  import AOC.Read, only: [fscan: 2]

  use AOC.Solution,
    title: "Movie Theater",
    url: "https://adventofcode.com/2025/day/9",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: false

  def parse(input) do
    for [x, y] <- fscan("~d,~d\n", input), do: {x, y}
  end

  def combinations(acc \\ [], list)
  def combinations(acc, [_]), do: Enum.concat(acc)

  def combinations(acc, [a | rest]) do
    res = for(b <- rest, do: {a, b})
    combinations([res | acc], rest)
  end

  def area({{x, y}, {i, j}}), do: (abs(i - x) + 1) * (abs(j - y) + 1)

  def silver(input) do
    input
    |> combinations()
    |> Stream.map(&area/1)
    |> Enum.max()
    |> inspect(charlists: :as_lists)
  end

  def gold(_input) do
    "Not implemented"
  end

end
