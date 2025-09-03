defmodule AOC.Y2019.Day8 do
  use AOC.Solution,
    title: "Space Image Format",
    url: "https://adventofcode.com/2019/day/8",
    scheme: {:separate, &silver/1, &gold/1},
    complete: false

  @dims %{x: 25, y: 6}
  @layer_size @dims.x * @dims.y

  def find_best(bin, best \\ nil, left \\ @layer_size, totals \\ {0, 0, 0})
  def find_best(<<>>, {_, o, t}, @layer_size, _totals), do: o * t

  def find_best(bin, best, 0, totals) do
      if is_nil(best) or elem(totals, 0) < elem(best, 0) do
        find_best(bin, totals)
      else
        find_best(bin, best)
      end
  end

  def find_best(<<n::8, rest::binary>>, best, left, totals) do
    totals = update_in(totals, [Access.elem(n - ?0)], &(&1 + 1))
    find_best(rest, best, left - 1, totals)
  end

  def silver(pixels), do: find_best(pixels)

  def gold(_pixels) do
    "Not implemented"
  end
end
