defmodule AOC.Y2015.Day8 do
  @moduledoc title: "Matchsticks"
  @moduledoc url: "https://adventofcode.com/2015/day/8"

  use AOC.Solvers.Chain, [2015, 8, &parse/1, &silver/1, &gold/1]

  def parse(input), do: String.splitter(input, "\n", trim: true)

  def silver(input) do
    Enum.reduce(input, 0, fn
      str, acc ->
        a = String.length(str)
        b = (Regex.scan(~r/\\\\|\\"|\\x..|./, str) |> length()) - 2
        acc + a - b
    end)
  end

  def gold(input) do
    Enum.reduce(input, 0, fn str, acc ->
      a = String.length(str)
      b =
        for match <- Regex.scan(~r/(\\|")|(.)/, str, capture: :all_but_first),
            reduce: 2 do acc ->
              case length(match) do
                1 -> acc + 2
                2 -> acc + 1
              end
            end
      acc + b - a
    end)
  end

end
