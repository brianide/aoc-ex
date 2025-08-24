defmodule AOC.Y2015.Day3 do
  @moduledoc title: "Perfectly Spherical Houses in a Vacuum"
  @moduledoc url: "https://adventofcode.com/2015/day/3"

  use AOC.Solvers.Chain, [2015, 3, &parse/1, &silver/1, &gold/1]

  def parse(input) do
    String.to_charlist(input)
  end

  defp offset(?>), do: {1, 0}
  defp offset(?<), do: {-1, 0}
  defp offset(?^), do: {0, 1}
  defp offset(?v), do: {0, -1}

  defp add({a, b}, {x, y}), do: {a + x, b + y}

  def silver(input) do
    for ch <- input,
        reduce: {{0, 0}, MapSet.new([{0, 0}])} do
          {p, seen} ->
            p = offset(ch) |> add(p)
            {p, MapSet.put(seen, p)}
        end
        |> elem(1)
        |> MapSet.size()
  end

  def gold(input) do
    for ch <- input,
        reduce: {{0, 0}, {0, 0}, MapSet.new([{0, 0}])} do
          {a, b, seen} ->
            a = offset(ch) |> add(a)
            {b, a, MapSet.put(seen, a)}
        end
        |> elem(2)
        |> MapSet.size()
  end

end
