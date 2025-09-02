defmodule AOC.Util.Zipper.ListZipper do
  def from_list([h | rest]), do: {h, [], rest}
  def to_list({foc, left, right}), do: Enum.reverse(left) ++ [foc | right]
  def left({foc, [l | rest], right}), do: {l, rest, [foc | right]}
  def right({foc, left, [r | rest]}), do: {r, [foc | left], rest}
  def replace({_, left, right}, n), do: {n, left, right}
  def update({n, left, right}, func), do: {func.(n), left, right}

  def front({_, [], _} = zip), do: zip
  def front(zip), do: left(zip) |> front()

  def back({_, _, []} = zip), do: zip
  def back(zip), do: right(zip) |> back()

  def reverse({foc, left, right}), do: {foc, right, left}

  def find_left({_foc, [], _right}, _pred), do: :error

  def find_left(zip, pred) do
    {foc, _, _} = zip = left(zip)
    if pred.(foc) do
      {:ok, zip}
    else
      find_left(zip, pred)
    end
  end

  def find_right({_foc, _left, []}, _pred), do: :error

  def find_right(zip, pred) do
    {foc, _, _} = zip = right(zip)
    if pred.(foc) do
      {:ok, zip}
    else
      find_right(zip, pred)
    end
  end
end
