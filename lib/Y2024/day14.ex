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

  @dims %{width: 101, height: 103}

  defp wrap(x, lim), do: rem(rem(x, lim) + lim, lim)
  defp move({x, y}, {dx, dy}, mag), do: {wrap(x + dx * mag, @dims.width), wrap(y + dy * mag, @dims.height)}

  defp classify(ps) do
    mw = div(@dims.width, 2)
    mh = div(@dims.height, 2)
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

  def silver(input) do
    Stream.map(input, fn {pos, vel} -> move(pos, vel, 100) end)
    |> classify()
  end

  defp print_pbm(ps, count) do
    cells = MapSet.new(ps)
    filenum = String.pad_leading("#{count}", 6, "0")

    vals =
      (for y <- 0..(@dims.height - 1),
           x <- 0..(@dims.height - 1),
           do: if MapSet.member?(cells, {x, y}), do: 0, else: 1)
      |> Enum.join()

    File.write!("_image/day13_#{filenum}.pbm", "P1\n#{@dims.width} #{@dims.height}\n#{vals}")
  end

  defp render(ps, init, count \\ 1) do
    res = Enum.map(ps, fn {pos, vel} -> move(pos, vel, count) end)

    if res === init do
      "Looped at #{count}"
    else
      print_pbm(res, count)
      render(ps, init, count + 1)
    end
  end

  def gold(input), do: render(input, Enum.map(input, &elem(&1, 0)))

end
