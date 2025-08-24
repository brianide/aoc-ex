defmodule AOC.Y2015.Day2 do
  @moduledoc title: "I Was Told There Would Be No Math"
  @moduledoc url: "https://adventofcode.com/2015/day/2"

  use AOC.Solvers.Double, [2015, 2, &parse/1, &solve/1]

  def parse(input) do
    Regex.scan(~r/\d+/, input)
    |> Stream.map(&List.first/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.chunk_every(3)
  end

  def solve(input) do
    for line <- input,
        [l, w, h] = Enum.sort(line),
        [a, b, c] = Enum.sort([l * w, w * h, h * l]),
        paper = 3 * a + 2 * b + 2 * c,
        ribbon = 2 * l + 2 * w + l * w * h,
        reduce: {0, 0} do {tpaper, tribbon} -> {tpaper + paper, tribbon + ribbon} end
  end

end
