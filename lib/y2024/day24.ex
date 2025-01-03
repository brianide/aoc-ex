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
        [a, b] = Enum.sort([a, b])
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

  defp is_reg?(k, ls), do: String.first(k) in ls

  def gold(input) do
    last_z = key_stream("z") |> Stream.take_while(&is_map_key(input, &1)) |> Enum.reverse() |> List.first()

    rule1 =
      Enum.filter(input, fn
        {k, {op, _, _}} when op !== :xor ->
          is_reg?(k, ~w/z/) && k !== last_z
        _ ->
          false
      end)

    rule2 =
      Enum.filter(input, fn
        {k, {:xor, {:var, a}, {:var, b}}} ->
          not is_reg?(k, ~w/z/) && not is_reg?(a, ~w/x y/) && not is_reg?(b, ~w/x y/)
        _ ->
          false
      end)

    rule3 =
      Enum.filter(input, fn
        {k, {:xor, {:var, a}, {:var, b}}} when a !== "x00" and b !== "y00" ->
          is_reg?(a, ~w/x/) && is_reg?(b, ~w/y/) && not Enum.any?(input, fn {_, {:xor, {:var, a}, {:var, b}}} -> a === k || b === k; _ -> false end)
        _ ->
          false
      end)

    rule4 =
      Enum.filter(input, fn
        {k, {:and, {:var, a}, {:var, b}}} when a !== "x00" and b !== "y00"  ->
          not Enum.any?(input, fn {_, {:or, {:var, a}, {:var, b}}} -> a === k || b === k; _ -> false end)
        _ ->
          false
      end)

    Stream.concat([rule1, rule2, rule3, rule4])
    |> Stream.map(&elem(&1, 0))
    |> Enum.sort()
    |> Enum.dedup()
    |> Enum.join(",")
  end

end
