defmodule AOC.Y2025.Day6 do
  use AOC.Solution,
    title: "Trash Compactor",
    url: "https://adventofcode.com/2025/day/6",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: false

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

  def silver(input) do
    for col <- input, {op, vals} = col, reduce: 0 do
      acc ->
        acc + Enum.reduce(vals, op)
    end
  end

  def gold(_input) do
    "Not implemented"
  end

end
