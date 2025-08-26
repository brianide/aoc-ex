defmodule AOC.Y2015.Day8 do

  use AOC.Solution,
    title: "Matchsticks",
    url: "https://adventofcode.com/2015/day/8",
    scheme: {:once, &parse/1, &solve/1}

  def parse(input), do: String.splitter(input, "\n", trim: true)

  def solve(input) do
    Enum.reduce(input, {0, 0}, fn
      str, {s, g} ->
        a = String.length(str)
        b = (Regex.scan(~r/\\\\|\\"|\\x..|./, str) |> length()) - 2

        c = String.to_charlist(str) |> Enum.count(&(&1 in [?\\, ?"]))

        {s + a - b, g + c + 2}
    end)
  end

end
