defmodule Day1 do
  def parse(filename) do
    File.read!(filename)
    |> then(&Regex.scan(~r/\d+/, &1))
    |> Enum.map(fn a -> List.first(a) |> String.to_integer() end)
    |> then(&parse([], [], &1))
  end
  def parse(a, b, [ha, hb | rest]), do: parse([ha | a], [hb | b], rest)
  def parse(a, b, []), do: {a, b}

  def silver({a, b}) do
    a = Enum.sort(a)
    b = Enum.sort(b)

    Enum.zip(a, b)
    |> Enum.map(fn {a, b} -> abs(b - a) end)
    |> Enum.sum()
  end

  def gold({a, b}) do
    keys = Enum.concat(a, b) |> Enum.uniq()
    a = Enum.frequencies(a)
    b = Enum.frequencies(b)

    keys
    |> Enum.map(fn k -> Map.get(a, k, 0) * Map.get(b, k, 0) * k end)
    |> Enum.sum()
  end
end

System.argv()
|> List.first()
|> Day1.parse()
|> then(fn input -> "#{Day1.silver(input)}\n#{Day1.gold(input)}" end)
|> IO.puts()
