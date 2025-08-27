defmodule AOC.Y2015.Day9 do

  use AOC.Solution,
    title: "All in a Single Night",
    url: "https://adventofcode.com/2015/day/9",
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
