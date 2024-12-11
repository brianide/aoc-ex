defmodule AOC.Y2024.Day11 do
  @moduledoc title: "Plutonian Pebbles"
  @moduledoc url: "https://adventofcode.com/2024/day/11"

  def solver, do: AOC.Scaffold.chain_solver(2024, 11, &parse/1, &silver/1, &gold/1)

  def parse(input), do: Regex.scan(~r/\d+/, input) |> Enum.map(fn ss -> List.first(ss) |> String.to_integer() end)

  defp digits(a), do: :math.log10(a + 1) |> ceil()

  defp update_stone(0), do: [1]
  defp update_stone(n) do
    len = digits(n)
    if rem(len, 2) === 0 do
      d = 10 ** div(len, 2)
      [div(n, d), rem(n, d)]
    else
      [n * 2024]
    end
  end

  defp update(list, 0), do: list
  defp update(list, n) do
    list
    |> Enum.flat_map(&update_stone/1)
    |> update(n - 1)
  end

  def silver(input) do
    update(input, 25) |> length()
  end

  def gold(_input) do
    "Not implemented"
  end

end
