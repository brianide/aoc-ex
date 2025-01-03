defmodule AOC.Y2019.Day1 do
  @moduledoc title: "The Tyranny of the Rocket Equation"
  @moduledoc url: "https://adventofcode.com/2019/day/1"

  def solver, do: AOC.Scaffold.chain_solver(2019, 1, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    for s <- String.split(input, "\n") do String.to_integer(s) end
  end

  def silver(input) do
    for n <- input, reduce: 0 do acc -> acc + div(n, 3) - 2 end
  end

  def calc_fuel(mass) do
    case div(mass, 3) - 2 do
      n when n <= 0 -> 0
      n -> n + calc_fuel(n)
    end
  end

  def gold(input) do
    for n <- input, reduce: 0 do acc -> acc + calc_fuel(n) end
  end

end
