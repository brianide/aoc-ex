defmodule AOC.Y2025.Day7 do
  use AOC.Solution,
    title: "Laboratories",
    url: "https://adventofcode.com/2025/day/7",
    scheme: {:once, &parse/1, &solve/1},
    complete: false

  def parse(input) do
    for line <- String.split(input) |> Stream.drop(1) |> Stream.drop_every(2),
        line = String.to_charlist(line),
        reduce: [] do
      acc ->
        Enum.zip_reduce(line, Stream.iterate(0, &(&1 + 1)), [], fn
          ?^, ind, acc -> [ind | acc]
          _, _, acc -> acc
        end)
        |> case do
          inds -> [MapSet.new(inds) | acc]
        end
    end
    |> Enum.reverse()
    |> case do
      [start | _] = lines -> {Enum.at(start, 0), lines}
    end
  end

  def tally(beams, [], total), do: {total, Enum.sum_by(beams, &elem(&1, 1))}

  def tally(beams, [splits | lines], total) do
    for {ind, n} = beam <- beams, reduce: {[], 0} do
      {acc, count} ->
        if MapSet.member?(splits, ind) do
          left = {ind - 1, n}
          right = {ind + 1, n}
          {[left, right | acc], count + 1}
        else
          {[beam | acc], count}
        end
    end
    |> case do
      {beams, count} ->
        for {ind, n} <- beams, reduce: %{} do
          acc -> Map.update(acc, ind, n, &(&1 + n))
        end
        |> tally(lines, total + count)
    end
  end

  def solve({start, lines}), do: tally(%{start => 1}, lines, 0)
end
