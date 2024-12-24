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
        op = case op do "AND" -> :and; "OR" -> :or; "XOR" -> :xor end
        {c, {op, a, b}}
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

  defp key_stream(var), do: Stream.unfold(0, fn acc -> {var <> String.pad_leading("#{acc}", 2, "0"), acc + 1} end)

  defp value_of(table, var) do
    key_stream(var)
    |> Stream.map(&Map.get(table, &1))
    |> Stream.take_while(&(&1))
    |> Stream.map(&simplify_until_const(&1, table))
    |> Enum.reverse()
    |> Enum.reduce(0, fn n, acc -> acc |> Bitwise.bsl(1) |> Bitwise.bor(n) end)
  end

  def silver(input), do: value_of(input, "z")

  # 1. If the output of a gate is z, then the operation has to be XOR unless it is the last bit.
  # 2. If the output of a gate is not z and the inputs are not x, y then it has to be AND / OR, but not XOR.
  # 3. If you have a XOR gate with inputs x, y, there must be another XOR gate with this gate as an input.
  #    Search through all gates for an XOR-gate with this gate as an input; if it does not exist, your (original) XOR gate is faulty.
  # 4. If you have an AND-gate, there must be an OR-gate with this gate as an input.
  #    If that gate doesn't exist, the original AND gate is faulty.

  def gold(input) do
    last_z = key_stream("z") |> Stream.take_while(&is_map_key(input, &1)) |> Enum.reverse() |> List.first()

    rule1 =
      Enum.filter(input, fn
        {k, {op, _, _}} when op !== :xor ->
          String.first(k) === "z" && k !== last_z
        _ ->
          false
      end)

    rule2 =
      Enum.filter(input, fn
        {k, {:xor, {:var, a}, {:var, b}}} ->
          String.first(k) !== "z" && String.first(a) not in ~w(x y) && String.first(b) not in ~w(x y)
        _ ->
          false
      end)

    rule3 =
      Enum.filter(input, fn
        {k, {:xor, {:var, a}, {:var, b}}} ->
          String.first(a) in ~w(x y) && String.first(b) in ~w(x y) && not Enum.any?(input, fn {_, {:xor, {:var, a}, {:var, b}}} -> a === k || b === k; _ -> false end)
        _ ->
          false
      end)

    rule4 =
      Enum.filter(input, fn
        {k, {:and, _, _}} ->
          not Enum.any?(input, fn {_, {:or, {:var, a}, {:var, b}}} -> a === k || b === k; _ -> false end)
        _ ->
          false
      end)

    Stream.concat([rule1, rule2, rule3, rule4])
    |> Stream.map(&elem(&1, 0))
    |> Enum.sort()
    |> Enum.join(",")
  end

end
