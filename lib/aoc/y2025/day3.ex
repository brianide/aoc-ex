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

  # def maximize([a, b | bank]), do: maximize(a, b, bank)

  # def maximize(msd, lsd, []), do: msd * 10 + lsd

  # def maximize(msd, lsd, [next | bank]) do
  #   cond do
  #     lsd > msd -> maximize(lsd, next, bank)
  #     next > lsd -> maximize(msd, next, bank)
  #     :else -> maximize(msd, lsd, bank)
  #   end
  # end

  def bump(bank), do: bump(bank, [])
  def bump([], prev), do: {false, Enum.reverse(prev)}
  def bump([a, b | bank], prev) when a > b, do: {true, Enum.reverse(prev) ++ [a | bank]}
  def bump([a | bank], prev), do: bump(bank, [a | prev])

  def maximize(size, bank) do
    {pre, post} = Enum.split(bank, size)
    maximize(size, Enum.reverse(pre), post)
  end

  def maximize(_size, sel, []) do
    for d <- Enum.reverse(sel),
        reduce: 0 do acc ->
          acc * 10 + d
        end
    |> tap(&IO.inspect/1)
  end

  def maximize(size, [head | rest] = sel, [next | bank]) do
    {bumped, sel} = bump(sel)
    cond do
      bumped -> maximize(size, [next | sel], bank)
      next > head -> maximize(size, [next | rest], bank)
      :else -> maximize(size, sel, bank)
    end
  end

  def solve(size, input) do
    for bank <- input,
        reduce: 0 do acc ->
          acc + maximize(size, bank)
        end
  end

  def silver(input), do: solve(2, input)

  def gold(input), do: solve(12, input)

end
