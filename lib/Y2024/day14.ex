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
    |> Stream.map(fn {-1, _} -> 1; {_, ls} -> length(ls) end)
    |> Enum.product()
  end

  defp print_pbm(ps, {w, h}, count) do
    cells = MapSet.new(ps)
    filenum = String.pad_leading("#{count}", 6, "0")

    vals =
      for y <- 0..(h - 1), x <- 0..(w - 1) do if MapSet.member?(cells, {x, y}), do: 0, else: 1 end
      |> Enum.join()

    cont = "P1\n#{w} #{h}\n#{vals}"
    File.write!("_image/day13_#{filenum}.pbm", cont)
  end

  def silver(input, dims \\ {101, 103}) do
    input
    |> Stream.map(fn {pos, vel} -> move(pos, vel, 100, dims) end)
    |> classify(dims)
  end

  defp render(ps, dims, seen \\ Map.new(), count \\ 0) do
    res = Enum.map(ps, fn {pos, vel} -> move(pos, vel, count, dims) end)
    print_pbm(res, dims, count)

    case Map.get(seen, res) do
      nil -> render(ps, dims, Map.put(seen, res, count), count + 1)
      n -> "Loop at #{count} (first at #{n})"
    end
  end

  def gold(input, dims \\ {101, 103}), do: render(input, dims)

end
