defmodule AOC.Y2015.Day1 do
  @moduledoc title: "Not Quite Lisp"
  @moduledoc url: "https://adventofcode.com/2015/day/1"

  use AOC.Solvers.Chain, [2015, 1, &parse/1, &silver/1, &gold/1]

  def parse(input), do: String.to_charlist(input)

  def silver(input) do
    Enum.reduce(input, 0, fn
      ?(, acc -> acc + 1
      ?), acc -> acc - 1
    end)
  end

  def gold(input) do
    Stream.scan(input, 0, fn
      ?(, acc -> acc + 1
      ?), acc -> acc - 1
    end)
    |> Enum.find_index(&(&1 < 0))
    |> case do n -> n + 1 end
  end

end
