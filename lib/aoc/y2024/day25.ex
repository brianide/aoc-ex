defmodule AOC.Y2024.Day25 do
  @moduledoc title: "Code Chronicle"
  @moduledoc url: "https://adventofcode.com/2024/day/25"

  def solver, do: AOC.Scaffold.chain_solver(2024, 25, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    count = fn e ->
      Enum.reduce(e, Stream.cycle([-1]), fn m, acc ->
        for {a, ch} <- Enum.zip(acc, m) do if ch !== ?#, do: a, else: a + 1  end
      end)
    end

    String.split(input, "\n\n")
    |> Stream.map(&(String.split(&1, "\n") |> Enum.map(fn s -> String.to_charlist(s) end)))
    |> Enum.split_with(fn [head | _] -> ?. not in head end)
    |> case do
      {locks, keys} -> {Enum.map(locks, count), Enum.map(keys, count)}
    end
  end

  def silver({locks, keys}) do
    for lock <- locks,
        key <- keys,
        reduce: 0 do acc ->
          Stream.zip(lock, key)
          |> Enum.all?(fn {a, b} -> a + b <= 5 end)
          |> if do
            acc + 1
          else
            acc
          end
        end
  end

  def gold(_), do: "Merry Christmas"

end
