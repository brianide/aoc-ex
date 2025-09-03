defmodule AOC.Y2019.Day10 do
  use AOC.Solution,
    title: "Monitoring Station",
    url: "https://adventofcode.com/2019/day/10",
    scheme: {:chain, &parse/1, &silver/1, &gold/2},
    complete: true

  alias AOC.Util.Point

  def parse(input) do
    AOC.Util.parse_map(input, dims: false)
    |> case do
      %{?# => coords} -> coords
    end
    |> Enum.map(fn {y, x} -> {x, y} end)
  end

  def gcd(0, b), do: b |> abs()
  def gcd(a, b), do: gcd(rem(b, a), a)

  def simplify({a, b}) do
    d = gcd(a, b)
    {div(a, d), div(b, d)}
  end

  def silver(coords) do
    Enum.map(coords, fn loc ->
      for other <- coords,
          loc != other,
          reduce: %{} do
        acc ->
          slope = Point.sub(other, loc) |> simplify()
          update_in(acc, [Access.key(slope, [])], &[other | &1])
      end
      |> case(do: (m -> {map_size(m), {m, loc}}))
    end)
    |> Enum.max_by(&elem(&1, 0))
  end

  def gold(_coords, {slopes, loc}) do
    key = fn {{x, y}, _} ->
      cond do
        x == 0 and y < 0 -> {0, 0}
        x > 0 and y < 0 -> {1, y / x}
        x > 0 and y >= 0 -> {2, y / -x}
        x == 0 and y > 0 -> {3, 0}
        x <= 0 and y > 0 -> {4, -y / -x}
        x < 0 and y <= 0 -> {5, -y / -x}
      end
    end

    slopes
    |> Enum.sort_by(key)
    |> Enum.at(199)
    |> then(&elem(&1, 1))
    |> Enum.min_by(&AOC.Util.Point.dist(&1, loc))
    |> case do {x, y} -> x * 100 + y end
  end
end
