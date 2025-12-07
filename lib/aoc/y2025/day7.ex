defmodule AOC.Y2025.Day7 do
  use AOC.Solution,
    title: "Laboratories",
    url: "https://adventofcode.com/2025/day/7",
    scheme: {:once, &parse/1, &solve/1},
    complete: false

  def parse(input) do
    [a, input] = String.split(input, "S")
    start = String.length(a)

    [_ | rest] = String.split(input, "\n")
    for line <- rest, line = String.to_charlist(line), reduce: [] do
      acc ->
        Enum.zip_reduce(line, Stream.iterate(0, &(&1 + 1)), [], fn
          ?^, ind, acc -> [ind | acc]
          _ch, _ind, acc -> acc
        end)
        |> case do
          [] -> acc
          inds -> [MapSet.new(inds) | acc]
        end
    end
    |> case do
      lines -> {start, Enum.reverse(lines)}
    end
  end

  def tally(beams, [], total), do: {beams, total}

  def tally(beams, [splits | lines], total) do
    for {ind, n} <- beams, reduce: {[], 0} do
      {acc, count} ->
        if MapSet.member?(splits, ind) do
          left = {ind - 1, n}
          right = {ind + 1, n}
          {[left, right | acc], count + 1}
        else
          {[{ind, n} | acc], count}
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

  def solve({start, lines}) do
    {a, b} = tally(%{start => 1}, lines, 0)
    {Enum.sum_by(a, fn {_, v} -> v end), b}
  end
end
