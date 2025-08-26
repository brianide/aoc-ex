defmodule AOC.Y2024.Day7 do

  use AOC.Solution,
    title: "Bridge Repair",
    url: "https://adventofcode.com/2024/day/7",
    scheme: {:shared, &parse/1, &silver/1, &gold/1}

  defp parse_line(line) do
    Regex.scan(~r/\d+/, line)
    |> Stream.map(&List.first/1)
    |> Enum.map(&String.to_integer/1)
    |> case do [head | rest] -> {head, rest} end
  end

  def parse(input) do
    String.split(input, "\n")
    |> Enum.map(&parse_line/1)
  end

  defp concat(a, b) do
    a * 10 ** (:math.log10(b + 1) |> ceil()) + b
  end

  defp search(targ, terms, do_cat), do: search(targ, 0, terms, do_cat)
  defp search(targ, total, [], _) when total == targ, do: true
  defp search(targ, total, _, _) when total > targ, do: false
  defp search(_, _, [], _), do: false
  defp search(targ, total, [h | rest], do_cat) do
    cond do
      search(targ, total + h, rest, do_cat) -> true
      search(targ, total * h, rest, do_cat) -> true
      do_cat && search(targ, concat(total, h), rest, do_cat) -> true
      :else -> false
    end
  end

  defp solve(input, do_cat) do
    input
    |> Task.async_stream(fn {targ, terms} -> search(targ, terms, do_cat) && targ || 0 end)
    |> Enum.reduce(0, fn {:ok, n}, acc -> acc + n end)
  end

  def silver(input), do: solve(input, false)
  def gold(input), do: solve(input, true)

end
