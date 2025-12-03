defmodule AOC.Y2025.Day3 do
  use AOC.Solution,
    title: "Lobby",
    url: "https://adventofcode.com/2025/day/3",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: false

  def parse(input) do
    for line <- String.split(input, "\n") do
      for g <- String.graphemes(line) do
        String.to_integer(g)
      end
    end
  end

  def maximize([a, b | bank]), do: maximize(a, b, bank)

  def maximize(msd, lsd, []), do: msd * 10 + lsd

  def maximize(msd, lsd, [next | bank]) do
    cond do
      lsd > msd -> maximize(lsd, next, bank)
      next > lsd -> maximize(msd, next, bank)
      :else -> maximize(msd, lsd, bank)
    end
  end

  def silver(input) do
    for bank <- input,
        reduce: 0 do acc ->
          acc + maximize(bank)
        end
  end

  def gold(_input) do
    "Not implemented"
  end

end
