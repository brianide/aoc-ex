defmodule AOC.Y2024.Day1 do

  use AOC.Solution,
    title: "Historian Hysteria",
    url: "https://adventofcode.com/2024/day/1",
    scheme: {:shared, &parse/1, &silver/1, &gold/1}

  def parse(input) do
    Regex.scan(~r/\d+/, input)
    |> Enum.map(fn a -> List.first(a) |> String.to_integer() end)
    |> then(&parse([], [], &1))
  end
  def parse(a, b, [ha, hb | rest]), do: parse([ha | a], [hb | b], rest)
  def parse(a, b, []), do: {a, b}

  def silver({a, b}) do
    for {a, b} <- Stream.zip(Enum.sort(a), Enum.sort(b)),
        reduce: 0 do
          acc -> acc + abs(b - a)
        end
  end

  def gold({a, b}) do
    freq = Enum.frequencies(b)
    for a <- a,
        reduce: 0 do
          acc -> acc + Map.get(freq, a, 0)
        end
  end

end
