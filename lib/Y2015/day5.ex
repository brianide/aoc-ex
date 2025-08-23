defmodule AOC.Y2015.Day5 do
  @moduledoc title: "Doesn&apos;t He Have Intern-Elves For This?"
  @moduledoc url: "https://adventofcode.com/2015/day/5"

  def solver, do: AOC.Scaffold.chain_solver(2015, 5, &parse/1, &silver/1, &gold/1)

  def parse(input), do: String.split(input, ~r/\n/) |> Enum.map(&String.to_charlist/1)

  defp check_line(line) do
    Enum.count(line, fn n -> n in ~c"aeiou" end) >= 3
    && Stream.chunk_every(line, 2, 1, :discard) |> Enum.any?(fn [a, b] -> a == b end)
    && Stream.chunk_every(line, 2, 1, :discard) |> Enum.all?(fn pr -> pr not in [~c"ab", ~c"cd", ~c"pq", ~c"xy"] end)
  end

  def silver(input) do
    Task.async_stream(input, &check_line/1)
    |> Enum.reduce(0, fn
      {:ok, true}, acc -> acc + 1
      _, acc -> acc
    end)
  end

  defp check_gold_pair([_, _]), do: false
  defp check_gold_pair([a, b | rest]) do
    Stream.chunk_every(rest, 2, 1, :discard)
    |> Enum.any?(fn pr -> pr == [a, b] end)
    |> case do
      true -> true
      false -> check_gold_pair([b | rest])
    end
  end

  defp check_gold_triple(line) do
    Stream.chunk_every(line, 3, 1, :discard)
    |> Enum.any?(fn [a, _, b] -> a == b end)
  end

  defp check_line_gold(line) do
    check_gold_pair(line) && check_gold_triple(line)
  end

  def gold(input) do
    Task.async_stream(input, &check_line_gold/1)
    |> Enum.reduce(0, fn
      {:ok, true}, acc -> acc + 1
      _, acc -> acc
    end)
  end

end
