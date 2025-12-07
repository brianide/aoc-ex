defmodule AOC.Y2025.Day7 do
  use AOC.Solution,
    title: "Laboratories",
    url: "https://adventofcode.com/2025/day/7",
    scheme: {:once, &parse/1, &solve/1},
    complete: true

  def parse_line(splits \\ [], ind \\ 0, chars) do
    case chars do
      [] -> MapSet.new(splits)
      [?S | _] -> ind
      [?^ | rest] -> parse_line([ind | splits], ind + 1, rest)
      [_ | rest] -> parse_line(splits, ind + 1, rest)
    end
  end

  def parse(input) do
    for line <- String.split(input) |> Stream.take_every(2),
        line = String.to_charlist(line),
        reduce: [] do
      acc -> [parse_line(line) | acc]
    end
    |> Enum.reverse()
    |> case do
      [start | lines] -> {start, lines}
    end
  end

  def tally(beams, [], total), do: {total, Enum.sum_by(beams, &elem(&1, 1))}

  def tally(beams, [splits | lines], total) do
    for {ind, n} <- beams, reduce: {%{}, 0} do
      {acc, count} ->
        if MapSet.member?(splits, ind) do
          acc =
            acc
            |> Map.update(ind - 1, n, &(&1 + n))
            |> Map.update(ind + 1, n, &(&1 + n))

          {acc, count + 1}
        else
          acc = Map.update(acc, ind, n, &(&1 + n))
          {acc, count}
        end
    end
    |> case do
      {beams, count} -> tally(beams, lines, total + count)
    end
  end

  def solve({start, lines}), do: tally(%{start => 1}, lines, 0)
end
