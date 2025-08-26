defmodule AOC.Y2015.Day5 do

  use AOC.Solution,
    title: "Doesn't He Have Intern-Elves For This?",
    url: "https://adventofcode.com/2015/day/5",
    scheme: {:shared, &parse/1, &silver/1, &gold/1}

  def parse(input), do: String.split(input, ~r/\n/) |> Enum.map(&String.to_charlist/1)

  defp window(a, n), do: Stream.chunk_every(a, n, 1, :discard)

  defp solve(input, pred) do
    Task.async_stream(input, pred)
    |> Enum.reduce(0, fn
      {:ok, true}, acc -> acc + 1
      _, acc -> acc
    end)
  end

  defp check_silver(line) do
    Enum.count(line, fn n -> n in ~c"aeiou" end) >= 3
    && window(line, 2) |> Enum.any?(fn [a, b] -> a == b end)
    && window(line, 2) |> Enum.all?(&(&1 not in [~c"ab", ~c"cd", ~c"pq", ~c"xy"]))
  end

  def silver(input), do: solve(input, &check_silver/1)

  defp rule_4([_, _]), do: false
  defp rule_4([a, b | rest]) do
    window(rest, 2)
    |> Enum.any?(&(&1 == [a, b]))
    |> case do
      true -> true
      false -> rule_4([b | rest])
    end
  end

  defp rule_5(line) do
    window(line, 3)
    |> Enum.any?(fn [a, _, b] -> a == b end)
  end

  defp check_gold(line), do: rule_4(line) && rule_5(line)

  def gold(input), do: solve(input, &check_gold/1)

end
