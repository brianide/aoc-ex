defmodule AOC.Y2024.Day24 do
  @moduledoc title: "Crossed Wires"
  @moduledoc url: "https://adventofcode.com/2024/day/24"

  def solver, do: AOC.Scaffold.chain_solver(2024, 24, &parse/1, &silver/1, &gold/1)

  def parse(input) do
    [inits, gates] = String.split(input, "\n\n")
    inits =
      for [_, c, val] <- Regex.scan(~r/(.{3}): ([01])/, inits) do
        {c, {:const, String.to_integer(val)}}
      end

    gates =
      for [_, a, op, b, c] <- Regex.scan(~r/(.{3}) (AND|OR|XOR) (.{3}) -> (.{3})/, gates) do
        a = {:var, a}
        b = {:var, b}
        case op do
          "AND" -> {c, {:and, a, b}}
          "OR" -> {c, {:or, a, b}}
          "XOR" -> {c, {:xor, a, b}}
        end
      end

    Map.new(Stream.concat(inits, gates))
  end

  defp simplify({:var, key}, table), do: Map.get(table, key)
  defp simplify({:const, n}, _), do: {:const, n}
  defp simplify({:and, {:const, a}, {:const, b}}, _), do: {:const, Bitwise.band(a, b)}
  defp simplify({:or, {:const, a}, {:const, b}}, _), do: {:const, Bitwise.bor(a, b)}
  defp simplify({:xor, {:const, a}, {:const, b}}, _), do: {:const, Bitwise.bxor(a, b)}
  defp simplify({op, aexp, bexp}, table), do: {op, simplify(aexp, table), simplify(bexp, table)}

  defp simplify_until_const({:const, n}, _), do: n
  defp simplify_until_const(exp, table), do: simplify(exp, table) |> simplify_until_const(table)

  def silver(input) do
    Stream.unfold(0, fn acc -> {"z" <> String.pad_leading("#{acc}", 2, "0"), acc + 1} end)
    |> Stream.map(&Map.get(input, &1))
    |> Stream.take_while(&(&1))
    |> Stream.map(&simplify_until_const(&1, input))
    |> Enum.reverse()
    |> Enum.reduce(0, fn n, acc -> acc |> Bitwise.bsl(1) |> Bitwise.bor(n) end)
    |> inspect(charlists: :as_lists)
  end

  def gold(_input) do
    "Not implemented"
  end

end
