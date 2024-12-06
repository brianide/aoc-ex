defmodule AOC.Y2024.Day!DAY! do
  @moduledoc title: "!NAME!"
  @moduledoc url: "https://adventofcode.com/!YEAR!/day/!DAY!"

  def solver, do: AOC.Scaffold.chain_solver(!YEAR!, !DAY!, &parse/1, &silver/1, &gold/1)

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
