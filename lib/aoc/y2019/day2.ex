defmodule AOC.Y2019.Day2 do
  use AOC.Solution,
    title: "1202 Program Alarm",
    url: "https://adventofcode.com/2019/day/2",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: false

  def parse(input) do
    input
  end

  def silver(input) do
    input
    |> inspect(charlists: :as_lists)
  end

  def gold(_input) do
    "Not implemented"
  end

end
