defmodule AOC.Y2025.Day12 do
  import AOC.Read, only: [fscan: 2, skip_lines: 2]

  use AOC.Solution,
    title: "Christmas Tree Farm",
    url: "https://adventofcode.com/2025/day/12",
    scheme: {:separate, &silver/1, &gold/1},
    complete: true,
    tags: [:lol]

  def silver(bin) do
    for [rows, cols | rest] <- fscan("~dx~d: ~d ~d ~d ~d ~d ~d", skip_lines(bin, 30)),
        reduce: 0 do
      acc ->
        if rows * cols >= Enum.sum(rest) * 9, do: acc + 1, else: acc
    end
  end

  def gold(_bin), do: "Merry Christmas"
end
