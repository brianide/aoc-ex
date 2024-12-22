defmodule AOC.Y2024.Day22 do
  @moduledoc title: "Monkey Market"
  @moduledoc url: "https://adventofcode.com/2024/day/22"

  def solver, do: AOC.Scaffold.chain_solver(2024, 22, &parse/1, &silver/1, &gold/1)

  alias Bitwise, as: Bit

  def parse(input) do
    for [s] <- Regex.scan(~r/\d+/, input), do: String.to_integer(s)
  end

  @divisor 16777216
  defp next_number(n) do
    n = Bit.bxor(n, n * 64)
    n = rem(n, @divisor)
    n = Bit.bxor(n, div(n, 32))
    n = rem(n, @divisor)
    n = Bit.bxor(n, n * 2048)
    rem(n, @divisor)
  end

  defp nth_number(m, 0), do: m
  defp nth_number(m, n), do: nth_number(next_number(m), n - 1)

  def silver(input) do
    for n <- input,
        n = nth_number(n, 2000),
        reduce: 0 do acc -> acc + n end
  end

  def gold(_input) do
    "Not implemented"
  end

end
