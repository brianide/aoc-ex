defmodule AOC.Y2024.Day19 do
  @moduledoc title: "Linen Layout"
  @moduledoc url: "https://adventofcode.com/2024/day/19"

  use Memoize

  def solver, do: AOC.Scaffold.chain_solver(2024, 19, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    [towels, designs] = String.split(input, "\n\n")
    proc = &(String.split(&1, &2) |> Enum.map(fn s -> String.graphemes(s) end))
    towels = proc.(towels, ", ")
    designs = proc.(designs, "\n")
    {towels, designs}
  end

  defp verify([], _), do: true
  defmemop verify(rest, towels) do
    # IO.inspect(rest)
    towels
    |> Stream.filter(&List.starts_with?(rest, &1))
    |> Stream.map(&verify(Enum.drop(rest, length(&1)), towels))
    |> Enum.any?()
  end

  def silver({towels, designs}) do
    designs
    |> Enum.count(&verify(&1, towels))
    # |> inspect(charlists: :as_lists)
  end

  def gold(_input) do
    "Not implemented"
  end

end
