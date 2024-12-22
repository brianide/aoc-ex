defmodule AOC.Y2024.Day22 do
  @moduledoc title: "Monkey Market"
  @moduledoc url: "https://adventofcode.com/2024/day/22"

  def solver, do: AOC.Scaffold.chain_solver(2024, 22, &parse/1, &silver/1, &gold/1)

  alias Bitwise, as: Bit

  def parse(input) do
    for [s] <- Regex.scan(~r/\d+/, input), do: String.to_integer(s)
  end

  @divisor 16777216
  defp next_number(n) do
    n = Bit.bxor(n, n * 64)
    n = rem(n, @divisor)
    n = Bit.bxor(n, div(n, 32))
    n = rem(n, @divisor)
    n = Bit.bxor(n, n * 2048)
    rem(n, @divisor)
  end

  defp nth_number(m, 0), do: m
  defp nth_number(m, n), do: nth_number(next_number(m), n - 1)

  def silver(input) do
    for n <- input,
        n = nth_number(n, 2000),
        reduce: 0 do acc -> acc + n end
  end

  def sequences(seed) do
    Stream.iterate(seed, &next_number/1)
    |> Stream.take(2001)
    |> Stream.map(&rem(&1, 10))
    |> Stream.transform({nil, []}, fn
      curr, {nil, []} ->
        {[], {curr, []}}
      curr, {prev, ds} when length(ds) < 3 ->
        {[], {curr, [curr - prev | ds]}}
      curr, {prev, ds} ->
        ds = [curr - prev | Enum.take(ds, 3)]
        {[{ds, curr}], {curr, ds}}
    end)
    |> Enum.reverse()
    |> Map.new()
  end

  def gold(input) do
    for seed <- input,
        scores = sequences(seed),
        reduce: %{} do acc ->
          Map.merge(acc, scores, fn _, a, b -> a + b end)
        end
    |> Enum.max_by(&elem(&1, 1))
    |> case do {_, v} -> v end
  end

end
