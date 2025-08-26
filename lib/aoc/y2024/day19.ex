defmodule AOC.Y2024.Day19 do

  use AOC.Solution,
    title: "Linen Layout",
    url: "https://adventofcode.com/2024/day/19",
    scheme: {:once, &parse/1, &solve/1}

  def parse(input) do
    [towels, designs] = String.split(input, "\n\n")
    proc = &(String.split(&1, &2) |> Enum.map(fn s -> String.graphemes(s) end))
    towels = proc.(towels, ", ")
    designs = proc.(designs, "\n")
    {towels, designs}
  end

  defp verify([], _), do: 1
  defp verify(rest, towels) do
    case Process.get(rest) do
      nil ->
        for towel <- towels,
            List.starts_with?(rest, towel),
            reduce: 0 do acc ->
              rest = Enum.drop(rest, length(towel))
              acc + verify(rest, towels)
            end
        |> tap(&Process.put(rest, &1))
      prev -> prev
    end
  end

  def solve({towels, designs}) do
    for {:ok, count} <- Task.async_stream(designs, &verify(&1, towels)),
        reduce: {0, 0} do {valid, total} ->
          {(if count > 0, do: valid + 1, else: valid), total + count}
        end
  end

end
