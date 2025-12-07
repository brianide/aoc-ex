defmodule AOC.Y2025.Day7 do
  use AOC.Solution,
    title: "Laboratories",
    url: "https://adventofcode.com/2025/day/7",
    scheme: {:custom, &solve/1},
    newline: :preserve,
    complete: true

  def drop_line(<<?\n, rest::binary>>), do: rest
  def drop_line(<<_, rest::binary>>), do: drop_line(rest)

  def parse_line(<<ch, rest::binary>>, splits \\ [], ind \\ 0) do
    case ch do
      ?S -> {:start, ind, rest |> drop_line() |> drop_line()}
      ?\n -> {:line, MapSet.new(splits), drop_line(rest)}
      ?^ -> parse_line(rest, [ind | splits], ind + 1)
      _ -> parse_line(rest, splits, ind + 1)
    end
  end

  def tally(beams, <<>>, total), do: {total, Enum.sum_by(beams, &elem(&1, 1))}

  def tally(beams, bin, total) do
    {:line, splits, bin} = parse_line(bin)
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
      {beams, count} -> tally(beams, bin, total + count)
    end
  end

  def solve(input) do
    {:start, start, rest} = parse_line(input)
    tally(%{start => 1}, rest, 0)
  end
end
