defmodule AOC.Day5 do

  @behaviour AOC.Scaffold.Solution
  def solution_info, do: {2024, 5, "Print Queue"}

  use AOC.Scaffold.DoubleSolver

  def parse(input) do
    [order, updates] = String.split(input, "\n\n")

    order =
      String.split(order, "\n")
      |> Enum.map(fn s -> String.split(s, "|") |> Enum.map(&String.to_integer/1) |> List.to_tuple() end)
      |> MapSet.new()

    updates =
      String.split(updates, "\n")
      |> Enum.map(fn s -> String.split(s, ",") |> Enum.map(&String.to_integer/1) end)

    {order, updates}
  end

  defp check_update([_], _), do: :ok
  defp check_update([{lt, li} | rest], order) do
    Stream.map(rest, fn {rt, ri} -> {{lt, rt}, {li, ri}} end)
    |> Enum.find(fn {p, _} -> not MapSet.member?(order, p) end)
    |> case do
      nil -> check_update(rest, order)
      {_, idx} -> {:error, idx}
    end
  end

  defp patch_update(update, {li, ri}) do
    update = List.to_tuple(update)
    update
    |> put_elem(li, elem(update, ri))
    |> put_elem(ri, elem(update, li))
    |> Tuple.to_list()
  end

  defp correct_update(update, order, patched \\ false) do
    Enum.with_index(update)
    |> check_update(order)
    |> case do
      :ok -> {update, patched}
      {:error, p} -> patch_update(update, p) |> correct_update(order, true)
    end
  end

  defp get_middle_elem(update) do
    update
    |> List.to_tuple()
    |> then(&elem(&1, div(tuple_size(&1), 2)))
  end

  def solve({order, updates}) do
    updates
    |> Stream.map(&correct_update(&1, order))
    |> Stream.map(fn {update, patched} -> {get_middle_elem(update), patched} end)
    |> Enum.reduce({0, 0}, fn
      {n, false}, {s, g} -> {s + n, g}
      {n, true}, {s, g} -> {s, g + n}
    end)
  end

end
