defmodule AOC.Y2024.Day11 do
  @moduledoc title: "Plutonian Pebbles"
  @moduledoc url: "https://adventofcode.com/2024/day/11"

  use Memoize

  def solver, do: AOC.Scaffold.chain_solver(2024, 11, &parse/1, &solve(&1, 25), &solve(&1, 75))

  def parse(input) do
    for [s] <- Regex.scan(~r/\d+/, input), do: String.to_integer(s)
  end

  defp digits(a), do: :math.log10(a + 1) |> ceil()

  defp update_stone(_, 0), do: 1
  defp update_stone(0, r), do: update_stone(1, r - 1)
  defmemop update_stone(n, r) do
    len = digits(n)
    if rem(len, 2) === 0 do
      d = 10 ** div(len, 2)
      update_stone(div(n, d), r - 1) + update_stone(rem(n, d), r - 1)
    else
      update_stone(n * 2024, r - 1)
    end
  end

  def solve(input, depth) do
    for st <- input,
        reduce: 0,
        do: (acc -> acc + update_stone(st, depth))
  end

end
