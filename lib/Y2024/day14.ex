defmodule AOC.Y2024.Day14 do
  @moduledoc title: "Restroom Redoubt"
  @moduledoc url: "https://adventofcode.com/2024/day/14"

  def solver, do: AOC.Scaffold.chain_solver(2024, 14, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    Regex.scan(~r/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/, input)
    |> Stream.map(&tl/1)
    |> Stream.map(fn s -> Enum.map(s, &String.to_integer/1) end)
    |> Stream.map(fn [x, y, dx, dy] -> {{x, y}, {dx, dy}} end)
    |> Enum.to_list()
  end

  defp wrap(x, lim), do: rem(rem(x, lim) + lim, lim)

  defp move({x, y}, {dx, dy}, mag, {w, h}), do: {wrap(x + dx * mag, w), wrap(y + dy * mag, h)}

  defp classify(ps, {w, h}) do
    mw = div(w, 2)
    mh = div(h, 2)
    Enum.group_by(ps, fn
      {x, y} when x < mw and y < mh -> 0
      {x, y} when x > mw and y < mh -> 1
      {x, y} when x < mw and y > mh -> 2
      {x, y} when x > mw and y > mh -> 3
      _ -> -1
    end)
    |> tap(&IO.inspect/1)
    |> Stream.map(fn {-1, _} -> 1; {_, ls} -> length(ls) end)
    |> Enum.product()
  end

  defp print(ps, {w, h}) do
    cells = Enum.group_by(ps, &(&1)) |> Map.new(fn {k, v} -> {k, "#{length(v)}"} end)
    for y <- 0..(h - 1), x <- 0..(w - 1) do Map.get(cells, {x, y}, ".") end
    |> Stream.chunk_every(w)
    |> Stream.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def silver(input, dims \\ {101, 103}) do
    input
    |> Stream.map(fn {pos, vel} -> move(pos, vel, 100, dims) end)
    |> classify(dims)
  end

  defp render(ps, dims, count \\ 0) do
    IO.puts("### Frame #{count} ###")
    Enum.map(ps, fn {pos, vel} -> move(pos, vel, count, dims) end) |> print(dims)
    render(ps, dims, count + 1)
  end

  def gold(input, dims \\ {101, 103}), do: render(input, dims)

end
