defmodule AOC.Y2024.Day19 do
  @moduledoc title: "Linen Layout"
  @moduledoc url: "https://adventofcode.com/2024/day/19"

  use Memoize

  def solver, do: AOC.Scaffold.double_solver(2024, 19, &parse/1, &solve/1)

  def parse(input) do
    [towels, designs] = String.split(input, "\n\n")
    proc = &(String.split(&1, &2) |> Enum.map(fn s -> String.graphemes(s) end))
    towels = proc.(towels, ", ")
    designs = proc.(designs, "\n")
    {towels, designs}
  end

  defp verify([], _), do: 1
  defmemop verify(rest, towels) do
    for towel <- towels,
        List.starts_with?(rest, towel),
        reduce: 0 do acc ->
          rest = Enum.drop(rest, length(towel))
          acc + verify(rest, towels)
        end
  end

  def solve({towels, designs}) do
    counts = Enum.map(designs, &verify(&1, towels))
    {Enum.count(counts, &(&1 > 0)), Enum.sum(counts)}
  end

end
