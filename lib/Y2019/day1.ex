defmodule AOC.Y2019.Day1 do
  @moduledoc title: "The Tyranny of the Rocket Equation"
  @moduledoc url: "https://adventofcode.com/2019/day/1"

  def solver, do: AOC.Scaffold.chain_solver(2019, 1, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    for s <- String.split(input, "\n") do String.to_integer(s) end
  end

  def silver(input) do
    # for n <- input, reduce: 0 do acc -> acc + div(n, 2) - 2 end
    inspect(input)
  end

  def gold(_input) do
    "Not implemented"
  end

end
