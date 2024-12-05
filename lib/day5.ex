defmodule AOC.Day5 do

  @behaviour AOC.Scaffold.Solution
  def solution_info, do: {2024, 5, "Print Queue"}

  use AOC.Scaffold.ChainSolver

  def parse(input) do
    [order, updates] = String.split(input, "\n\n")

    order =
      String.split(order, "\n")
      |> Enum.map(fn s -> String.split(s, "|") |> Enum.map(&String.to_integer/1) |> List.to_tuple() end)

    updates =
      String.split(updates, "\n")
      |> Enum.map(fn s -> String.split(s, ",") |> Enum.map(&String.to_integer/1) end)

    {order, updates}
  end

  defp positions(update), do: positions([], update)
  defp positions(acc, [_]), do: acc
  defp positions(acc, [lt | rest]) do
    for rt <- rest, reduce: acc do
      acc -> [{lt, rt} | acc]
    end
    |> positions(rest)
  end

  defp check_update(update, order), do: positions(update) |> Enum.all?(&MapSet.member?(order, &1))

  def silver({order, updates}) do
    order = MapSet.new(order)

    updates
    |> Stream.filter(&check_update(&1, order))
    |> Stream.map(&List.to_tuple/1)
    |> Stream.map(&elem(&1, div(tuple_size(&1), 2)))
    |> Enum.sum()
  end

  def gold(_input) do
    ""
  end

end
