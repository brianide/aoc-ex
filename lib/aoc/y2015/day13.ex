defmodule AOC.Y2015.Day13 do
  use AOC.Solution,
    title: "Knights of the Dinner Table",
    url: "https://adventofcode.com/2015/day/13",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: true

  @regex ~r/(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)\./
  @types [:str, :str, :int, :str]
  def parse(input) do
    for [a, sign, val, b] <- AOC.Util.Regex.scan_typed(@regex, @types, input),
        val = (if sign == "gain", do: val, else: -1 * val),
        reduce: %{} do acc ->
          put_in(acc, [Access.key(a, %{}), b], val)
        end
  end

  def silver(input) do
    Map.keys(input)
    |> AOC.Util.permutations()
    |> Stream.map(fn list ->
      Enum.reduce(list, {List.last(list), 0}, fn a, {b, total} ->
        {a, total + input[a][b] + input[b][a]}
      end)
    end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.max()
  end

  def gold(input) do
    selfmap = for k <- Map.keys(input), reduce: %{}, do: (acc -> put_in(acc[k], 0))

    input
    |> Map.new(fn {k, v} -> {k, put_in(v[:me], 0)} end)
    |> put_in([:me], selfmap)
    |> silver()
  end

end
