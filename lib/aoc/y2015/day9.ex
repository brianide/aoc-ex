defmodule AOC.Y2015.Day9 do
  use AOC.Solution,
    title: "All in a Single Night",
    url: "https://adventofcode.com/2015/day/9",
    scheme: {:once, &parse/1, &solve/1},
    complete: true

  @regex ~r/(\w+) to (\w+) = (\d+)/
  @types [:str, :str, :int]
  def parse(input) do
    for [from, to, dist] <- AOC.Util.Regex.scan_typed(@regex, @types, input),
        reduce: %{} do acc ->
          acc
          |> put_in([Access.key(from, %{}), to], dist)
          |> put_in([Access.key(to, %{}), from], dist)
        end
  end

  def solve(input) do
    Map.keys(input)
    |> AOC.Util.permutations()
    |> Stream.map(fn list ->
      Enum.reduce(list, nil, fn
        dest, nil -> {dest, 0}
        dest, {prev, total} -> {dest, total + input[prev][dest]}
      end)
    end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.min_max()
  end

end
