defmodule AOC.Util.Point do

  def add({r, c}, {dr, dc}), do: {r + dr, c + dc}
  def sub({r, c}, {br, bc}), do: {r - br, c - bc}
  def mul({r, c}, m), do: {r * m, c * m}
  def dist({r, c}, {br, bc}), do: {abs(br - r), abs(bc - c)}

  @spec bounds(any()) :: {{number(), number()}, {number(), number()}}
  def bounds(points) do
    Enum.reduce(points, {{nil, nil}, {nil, nil}}, fn {r, c}, {{lr, lc}, {hr, hc}} ->
      lr = if lr != nil and lr < r, do: lr, else: r
      lc = if lc != nil and lc < c, do: lc, else: c
      hr = if hr != nil and hr > r, do: hr, else: r
      hc = if hc != nil and hc > c, do: hc, else: c
      {{lr, lc}, {hr, hc}}
    end)
  end

end
