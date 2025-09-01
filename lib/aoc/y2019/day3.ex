defmodule AOC.Y2019.Day3 do
  use AOC.Solution,
    title: "Crossed Wires",
    url: "https://adventofcode.com/2019/day/3",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: false

  def dir("U"), do: { 1,  0}
  def dir("D"), do: {-1,  0}
  def dir("R"), do: { 0,  1}
  def dir("L"), do: { 0, -1}

  def mul({r, c}, d), do: {r * d, c * d}
  def add({r, c}, {dr, dc}), do: {r + dr, c + dc}

  def points_between({ra, ca}, {rb, cb}) do
    if ra == rb do
      st = min(ca, cb)
      ed = max(ca, cb)
      for s <- st..ed, do: {ra, s}
    else
      st = min(ra, rb)
      ed = max(ra, rb)
      for s <- st..ed, do: {s, ca}
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
    |> plot_points()
    |> Stream.flat_map(fn n -> n end)
    |> MapSet.new()
  end

  def parse(input) do
    for line <- String.split(input, "\n"), do: parse_line(line)
  end

  def silver([a, b]) do
    for({a, b} <- MapSet.intersection(a, b), not (a == 0 and b == 0), do: abs(a) + abs(b))
    |> Enum.min()
  end

  def gold(_input) do
    "Not implemented"
  end

end
