defmodule AOC.Y2024.Day2 do
  @moduledoc title: "Red-Nosed Reports"
  @moduledoc url: "https://adventofcode.com/2024/day/2"

  def solver, do: AOC.Scaffold.double_solver(2024, 2, &parse/1, &solve/1)

  def parse(input) do
    String.split(input, "\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn s -> String.length(s) > 0 end)
    |> Enum.map(fn s -> String.split(s, ~r/ +/) |> Enum.map(&String.to_integer/1) end)
  end

  def check(input), do: check(:unset, input)
  def check(order, [a, b | rest]) do
    case {order, abs(b - a), Util.sign(b - a)} do
      {_, v, _} when v < 1 or v > 3 -> false
      {:unset, _, s} when s > 0 -> check(:asc, [b | rest])
      {:unset, _, s} when s < 0 -> check(:desc, [b | rest])
      {:asc, _, s} when s > 0 -> check(:asc, [b | rest])
      {:desc, _, s} when s < 0 -> check(:desc, [b | rest])
      _ -> false
    end
  end
  def check(_, [_]), do: true

  def check_alts(input) do
    Stream.unfold(0, fn
      x when x == length(input) -> nil
      x -> {List.delete_at(input, x), x + 1}
    end)
    |> Enum.any?(&check/1)
  end

  def solve(input) do
    Enum.reduce(input, {0, 0}, fn line, {s, g} ->
      cond do
        check(line) -> {s + 1, g + 1}
        check_alts(line) -> {s, g + 1}
        :else -> {s, g}
      end
    end)
  end

end
