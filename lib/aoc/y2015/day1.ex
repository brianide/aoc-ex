defmodule AOC.Y2015.Day1 do

  use AOC.Solution,
    title: "Not Quite Lisp",
    url: "https://adventofcode.com/2015/day/1",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: true

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
