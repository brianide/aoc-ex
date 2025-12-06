defmodule AOC.Y2025.Day6 do
  alias AOC.Y2025.Day6.Silver, as: Silver
  alias AOC.Y2025.Day6.Gold, as: Gold

  use AOC.Solution,
    title: "Trash Compactor",
    url: "https://adventofcode.com/2025/day/6",
    scheme: {:separate, &solve(Silver, &1), &solve(Gold, &1)},
    complete: false,
    tags: [:medium, :parsing]

  def solve(mod, input) do
    input
    |> then(&Kernel.apply(mod, :parse, [&1]))
    |> then(&Kernel.apply(mod, :solve, [&1]))
  end
end

defmodule AOC.Y2025.Day6.Silver do
  def parse_lines(coll \\ [], lines)

  def parse_lines(coll, [last]) do
    for [op] <- Regex.scan(~r/\S/, last) do
      case op do
        "*" -> &Kernel.*/2
        "+" -> &Kernel.+/2
      end
    end
    |> Enum.zip_with(coll, fn op, col -> {op, col} end)
  end

  def parse_lines(coll, [line | lines]) do
    for [i] <- Regex.scan(~r/\d+/, line) do
      String.to_integer(i)
    end
    |> case do
      row when coll == [] -> Enum.map(row, fn i -> [i] end)
      row -> Enum.zip_with(row, coll, fn i, col -> [i | col] end)
    end
    |> parse_lines(lines)
  end

  def parse(input) do
    String.split(input, "\n")
    |> parse_lines()
  end

  def solve(input) do
    for col <- input, {op, vals} = col, reduce: 0 do
      acc ->
        acc + Enum.reduce(vals, op)
    end
  end
end

defmodule AOC.Y2025.Day6.Gold do
  def transpose(rows), do: Enum.zip_with(rows, & &1)

  def parse(input) do
    for(line <- String.split(input, ~r/\n/), do: String.graphemes(line))
    |> transpose()
    |> Stream.map(&Enum.join/1)
    |> Enum.join("\n")
  end

  def solve(input) do
    for [_, n, op] <- Regex.scan(~r/(\d+)\s*([*+ ])/, input),
        n = String.to_integer(n),
        reduce: {0, nil, 0} do
      {sub, _, total} when op === "+" -> {n, &Kernel.+/2, total + sub}
      {sub, _, total} when op === "*" -> {n, &Kernel.*/2, total + sub}
      {sub, op, total} -> {op.(sub, n), op, total}
    end
    |> case do
      {sub, _, total} -> total + sub
    end
  end
end
