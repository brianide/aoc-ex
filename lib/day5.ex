defmodule AOC.Day5 do

  @behaviour AOC.Scaffold.Solution
  def solution_info, do: {2024, 5, "Print Queue"}

  use AOC.Scaffold.ChainSolver

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

  defp do_check_update([_], order), do: :ok
  defp do_check_update([{lt, li} | rest], order) do
    Stream.map(rest, fn {rt, ri} -> {{lt, rt}, {li, ri}} end)
    |> Enum.find(fn {p, _} -> not MapSet.member?(order, p) end)
    |> case do
      nil -> do_check_update(rest, order)
      {_, idx} -> {:error, idx}
    end
  end

  defp check_update(update, order) do
    Enum.with_index(update)
    |> do_check_update(order)
  end

  defp get_middle_elem(update) do
    update
    |> List.to_tuple()
    |> then(&elem(&1, div(tuple_size(&1), 2)))
  end

  def silver({order, updates}) do
    updates
    |> Stream.filter(fn u -> check_update(u, order) == :ok end)
    |> Stream.map(&get_middle_elem/1)
    |> Enum.sum()
  end

  defp patch_update(update, {li, ri}) do
    update = List.to_tuple(update)
    update
    |> put_elem(li, elem(update, ri))
    |> put_elem(ri, elem(update, li))
    |> Tuple.to_list()
  end

  defp correct_update(update, order, patched \\ false) do
    case check_update(update, order) do
      :ok -> {update, patched}
      {:error, p} -> patch_update(update, p) |> correct_update(order, true)
    end
  end

  def gold({order, updates}) do
    updates
    |> Stream.map(&correct_update(&1, order))
    |> Stream.filter(&elem(&1, 1))
    |> Stream.map(fn {update, _} -> get_middle_elem(update) end)
    |> Enum.sum()
  end

end
