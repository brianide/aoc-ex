defmodule AOC.Y2019.Day3 do
  use AOC.Solution,
    title: "Crossed Wires",
    url: "https://adventofcode.com/2019/day/3",
    scheme: {:chain, &parse/1, &silver/1, &gold/2},
    complete: true

  import AOC.Util.Point

  def dir("U"), do: { 1,  0}
  def dir("D"), do: {-1,  0}
  def dir("R"), do: { 0,  1}
  def dir("L"), do: { 0, -1}

  def points_between({ra, ca}, {rb, cb}) do
    if ra == rb do
      step = if ca < cb, do: 1, else: -1
      for s <- (ca + step)..cb//step, do: {ra, s}
    else
      step = if ra < rb, do: 1, else: -1
      for s <- (ra + step)..rb//step, do: {s, ca}
    end
  end

  def plot_points(line) do
    for [a, b] <- Stream.chunk_every(line, 2, 1, :discard), do: points_between(a, b)
  end

  def parse_line(line) do
    for [dir, dist] <- Regex.scan(~r/([RULD])(\d+)/, line, capture: :all_but_first),
        reduce: [{0, 0}] do [p | _] = acc ->
          dist = String.to_integer(dist)
          p = dir(dir) |> mul(dist) |> add(p)
          [p | acc]
        end
    |> Enum.reverse()
    |> plot_points()
    |> Enum.flat_map(fn n -> n end)
  end

  def parse(input) do
    for line <- String.split(input, "\n"), do: parse_line(line)
  end

  def silver(input) do
    inters = Enum.map(input, &MapSet.new/1) |> case do [a, b] -> MapSet.intersection(a, b) end
    min = Stream.map(inters, fn {a, b} -> abs(a) + abs(b) end) |> Enum.min()
    {min, inters}
  end

  def gold([a, b], inters) do
    Enum.map(inters, fn p -> Enum.find_index(a, &(&1 == p)) + Enum.find_index(b, &(&1 == p)) + 2 end)
    |> Enum.min()
  end

end
