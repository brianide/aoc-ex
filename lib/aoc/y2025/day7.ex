defmodule AOC.Y2025.Day7 do
  use AOC.Solution,
    title: "Laboratories",
    url: "https://adventofcode.com/2025/day/7",
    scheme: {:once, &parse/1, &solve/1},
    complete: true

  def drop_line(<<?\n, rest::binary>>), do: rest
  def drop_line(<<_, rest::binary>>), do: drop_line(rest)
  def drop_line(<<>>), do: <<>>

  def parse_line(<<ch, rest::binary>>, splits \\ [], ind \\ 0) do
    case ch do
      ?S -> {ind, rest |> drop_line() |> drop_line()}
      ?\n -> {MapSet.new(splits), drop_line(rest)}
      ?^ -> parse_line(rest, [ind | splits], ind + 1)
      _ -> parse_line(rest, splits, ind + 1)
    end
  end

  def parse_bin(bin, lines \\ []) do
    case parse_line(bin) do
      {res, <<>>} ->
        [start | lines] = Enum.reverse([res | lines])
        {start, lines}
      {res, rest} ->
        parse_bin(rest, [res | lines])
    end
  end

  def parse(input), do: parse_bin(input)

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
