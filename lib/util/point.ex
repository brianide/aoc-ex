defmodule AOC.Util.Point do

  def add({r, c}, {dr, dc}), do: {r + dr, c + dc}
  def sub({r, c}, {br, bc}), do: {r - br, c - bc}
  def dist({r, c}, {br, bc}), do: {abs(br - r), abs{bc - c}}

end
