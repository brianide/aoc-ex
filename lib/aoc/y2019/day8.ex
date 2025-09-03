defmodule AOC.Y2019.Day8 do
  use AOC.Solution,
    title: "Space Image Format",
    url: "https://adventofcode.com/2019/day/8",
    scheme: {:once, &(&1), &solve/1},
    complete: true

  @dims %{x: 25, y: 6}
  @layer_size @dims.x * @dims.y
  @base Stream.duplicate(2, @layer_size) |> Enum.to_list() |> List.to_tuple()

  def decode(bin, image \\ @base, best \\ nil, index \\ 0, totals \\ {0, 0, 0})
  def decode(<<>>, image, {_, o, t}, 0, _totals), do: {o * t, render(image)}

  def decode(bin, image, best, @layer_size, totals) do
    if is_nil(best) or elem(totals, 0) < elem(best, 0) do
      decode(bin, image, totals)
    else
      decode(bin, image, best)
    end
  end

  def decode(<<_::4, n::4, rest::binary>>, image, best, index, totals) do
    image = if elem(image, index) != 2, do: image, else: put_elem(image, index, n)
    totals = put_elem(totals, n, elem(totals, n) + 1)
    decode(rest, image, best, index + 1, totals)
  end

  @white IO.ANSI.white_background() <> " " <> IO.ANSI.default_background()
  def render(image) do
    for {p, i} <- Tuple.to_list(image) |> Stream.with_index(),
        color = (if p == 0, do: " ", else: @white),
        newl = (if i > 0 and rem(i, @dims.x) == 0, do: "\n", else: ""),
        into: <<>>,
        do:  newl <> color
  end

  def solve(pixels) do
    decode(pixels)
  end
end
