defmodule Util do
  def sign(x) when x > 0, do: 1
  def sign(x) when x < 0, do: -1
  def sign(_), do: 0
end
