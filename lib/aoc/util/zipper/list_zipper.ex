defmodule AOC.Util.Zipper.ListZipper do

  @type zipper() :: {list(), list()}

  @spec from_list(list()) :: zipper()
  def from_list(list), do: {[], list}

  @spec to_list(zipper()) :: list()
  def to_list({left, right}), do: Enum.reverse(left) ++ right

  @spec left(zipper()) :: zipper()
  def left({[l | left], right}), do: {left, [l | right]}

  @spec right(zipper()) :: zipper()
  def right({left, [r | right]}), do: {[r | left], right}

  @spec replace(zipper(), term()) :: zipper()
  def replace({left, [_ | right]}, n), do: {left, [n | right]}

  @spec update(zipper(), function()) :: zipper()
  def update({left, [r | right]}, func), do: {left, [func.(r) | right]}

  @spec insert(zipper(), term()) :: zipper()
  def insert({left, right}, n), do: {left, [n | right]}

  @spec front(zipper()) :: zipper()
  def front({[], _} = zip), do: zip
  def front(zip), do: left(zip) |> front()

  @spec back(zipper()) :: zipper()
  def back({_, []} = zip), do: zip
  def back(zip), do: right(zip) |> back()

  @spec reverse(zipper()) :: zipper()
  def reverse({left, right}), do: {right, left}

  @spec find_left(zipper(), function()) :: ({:ok, zipper()} | :error)
  def find_left({[], _right}, _pred), do: :error

  def find_left(zip, pred) do
    {_, [foc | _]} = zip = left(zip)
    if pred.(foc) do
      {:ok, zip}
    else
      find_left(zip, pred)
    end
  end

  @spec find_right(zipper(), function()) :: ({:ok, zipper()} | :error)
  def find_right({_left, []}, _pred), do: :error

  def find_right(zip, pred) do
    {_, [foc | _]} = zip = right(zip)
    if pred.(foc) do
      {:ok, zip}
    else
      find_right(zip, pred)
    end
  end
end
