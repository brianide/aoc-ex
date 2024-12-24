defmodule AOC.Util.Direction do

  def turn_right(:north), do: :east
  def turn_right(:east), do: :south
  def turn_right(:south), do: :west
  def turn_right(:west), do: :north

  def turn_left(:north), do: :west
  def turn_left(:west), do: :south
  def turn_left(:south), do: :east
  def turn_left(:east), do: :north

  def offset(:north), do: {-1, 0}
  def offset(:south), do: {1, 0}
  def offset(:east), do: {0, 1}
  def offset(:west), do: {0, -1}

end
