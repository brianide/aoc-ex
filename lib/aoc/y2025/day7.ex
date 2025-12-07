defmodule AOC.Y2025.Day7 do
  use AOC.Solution,
    title: "Laboratories",
    url: "https://adventofcode.com/2025/day/7",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
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

  def tally(_beams, [], total), do: total

  def tally(beams, [splits | lines], total) do
    for b <- beams, reduce: {[], 0} do
      {acc, count} ->
        if MapSet.member?(splits, b) do
          {[b - 1, b + 1 | acc], count + 1}
        else
          {[b | acc], count}
        end
    end
    |> case do
      {beams, count} -> MapSet.new(beams) |> tally(lines, total + count)
    end
  end

  def silver({start, lines}) do
    tally([start], lines, 0)
  end

  def gold(_input) do
    "Not implemented"
  end

end
