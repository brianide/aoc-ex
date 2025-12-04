defmodule AOC.Y2025.Day3 do
  use AOC.Solution,
    title: "Lobby",
    url: "https://adventofcode.com/2025/day/3",
    scheme: {:shared, &parse/1, &solve(2, &1), &solve(12, &1)},
    complete: true,
    favorite: true

  def parse(input) do
    for line <- String.split(input, "\n") do
      for g <- String.graphemes(line) do
        String.to_integer(g)
      end
    end
  end

  def maximize(size, bank), do: maximize([], length(bank) - size, bank)

  # Base case; truncate stack and convert back into a number
  def maximize(sel, rems, []), do: sel |> Enum.drop(rems) |> Enum.reverse() |> Enum.reduce(0, &(&1 + &2 * 10))

  # Pop from selection stack while bank head is larger and removals are left
  def maximize([sh | sel], rems, [bh | _] = bank) when bh > sh and rems > 0, do: maximize(sel, rems - 1, bank)

  # Transfer from bank to stack
  def maximize(sel, rems, [bh | bank]), do: maximize([bh | sel], rems, bank)

  def solve(size, input) do
    for bank <- input, reduce: 0, do: (acc -> acc + maximize(size, bank))
  end
end
