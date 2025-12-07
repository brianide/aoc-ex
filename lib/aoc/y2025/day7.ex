defmodule AOC.Y2025.Day7 do
  use AOC.Solution,
    title: "Laboratories",
    url: "https://adventofcode.com/2025/day/7",
    scheme: {:once, &parse/1, &solve/1},
    complete: true

  def parse(input) do
    for line <- String.split(input) |> Stream.drop(1) |> Stream.drop_every(2),
        line = String.to_charlist(line),
        reduce: [] do
      acc ->
        Enum.zip_reduce(line, Stream.iterate(0, &(&1 + 1)), MapSet.new(), fn
          ?^, ind, acc -> MapSet.put(acc, ind)
          _, _, acc -> acc
        end)
        |> case do
          inds -> [inds | acc]
        end
    end
    |> Enum.reverse()
    |> case do
      [start | _] = lines -> {Enum.at(start, 0), lines}
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
