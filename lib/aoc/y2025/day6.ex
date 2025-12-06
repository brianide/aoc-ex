defmodule AOC.Y2025.Day6 do
  alias AOC.Y2025.Day6.Silver, as: Silver
  alias AOC.Y2025.Day6.Gold, as: Gold

  use AOC.Solution,
    title: "Trash Compactor",
    url: "https://adventofcode.com/2025/day/6",
    scheme: {:separate, &Silver.solve/1, &Gold.solve/1},
    complete: true,
    tags: [:medium, :parsing]
end

defmodule AOC.Y2025.Day6.Silver do
  import AOC.Read, only: [fscan: 2]

  def get_operators(line) do
    for [op] <- Regex.scan(~r/[*+]/, line) do
      case op do
        "+" -> &Kernel.+/2
        "*" -> &Kernel.*/2
      end
    end
  end

  def solve(input) do
    String.splitter(input, "\n")
    |> Enum.reduce(nil, fn
      line, nil ->
        fscan("~d", line)

      line, cols ->
        case fscan("~d", line) do
          [] ->
            get_operators(line)
            |> Enum.zip_reduce(cols, 0, fn op, col, acc -> acc + Enum.reduce(col, op) end)

          vs ->
            Enum.zip_with(vs, cols, &Kernel.++/2)
        end
    end)
  end
end

defmodule AOC.Y2025.Day6.Gold do
  def read_cols(prev_cols \\ [], next_cols \\ [], [ch | chars]) do
    {prev, tail} =
      case prev_cols do
        [h | t] -> {h, t}
        _ -> {0, []}
      end

    case ch do
      ?\n ->
        read_cols(Enum.reverse(next_cols), [], chars)

      ?\s ->
        read_cols(tail, [prev | next_cols], chars)

      ch when ch in [?+, ?*] ->
        tally_cols(prev_cols, [ch | chars])

      ch ->
        val = prev * 10 + (ch - ?0)
        next_cols = [val | next_cols]
        read_cols(tail, next_cols, chars)
    end
  end

  def tally_cols(nums, chars, op \\ nil, sub \\ 0, total \\ 0)
  def tally_cols([], [], _op, sub, total), do: total + sub

  def tally_cols([num | nums], [ch | chars], op, sub, total) do
    cond do
      ch === ?* -> tally_cols(nums, chars, &Kernel.*/2, num, total)
      ch === ?+ -> tally_cols(nums, chars, &Kernel.+/2, num, total)
      num === 0 -> tally_cols(nums, chars, nil, nil, total + sub)
      :else -> tally_cols(nums, chars, op, op.(sub, num), total)
    end
  end

  def solve(input) do
    String.to_charlist(input)
    |> read_cols()
  end
end
