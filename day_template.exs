defmodule AOC.Y!YEAR!.Day!DAY! do

  use AOC.Solution,
    title: "!NAME!",
    url: "https://adventofcode.com/!YEAR!/day/!DAY!",
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
