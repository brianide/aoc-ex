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

  defp solve_for(table, var) do
    Stream.unfold(0, fn acc -> {var <> String.pad_leading("#{acc}", 2, "0"), acc + 1} end)
    |> Stream.map(&Map.get(table, &1))
    |> Stream.take_while(&(&1))
    |> Stream.map(&simplify_until_const(&1, table))
    |> Enum.reverse()
    |> Enum.reduce(0, fn n, acc -> acc |> Bitwise.bsl(1) |> Bitwise.bor(n) end)
  end

  def silver(input), do: solve_for(input, "z")

  defp recur(exp, table, cache) do
    case exp do
      {:var, k} when is_map_key(cache, k) ->
        {Map.get(cache, k), cache}
      {:var, k} ->
        {res, cache} = recur(Map.get(table, k), table, cache)
        {res, Map.put(cache, k, res)}
      {:const, n} ->
        {n, cache}
      {op, a, b} ->
        {a, cache} = recur(a, table, cache)
        {b, cache} = recur(b, table, cache)
        case op do
          :and -> Bitwise.band(a, b)
          :or -> Bitwise.bor(a, b)
          :xor -> Bitwise.bxor(a, b)
        end
        |> case do
          res -> {res, cache}
        end
    end
  end

  defp solve_recur(table, var) do
    Stream.unfold(0, fn acc -> {var <> String.pad_leading("#{acc}", 2, "0"), acc + 1} end)
    |> Stream.take_while(&is_map_key(table, &1))
    |> Enum.flat_map_reduce(%{}, fn key, cache ->
      {res, cache} = recur({:var, key}, table, cache)
      {[res], cache}
    end)
    |> case do
      {res, cache} ->
        res
        |> Enum.reverse()
        |> Enum.reduce(0, fn n, acc -> acc |> Bitwise.bsl(1) |> Bitwise.bor(n) end)
        |> case do n -> {n, cache} end
    end
  end

  def gold(input) do
    solve_recur(input, "z")
    |> inspect()
    # sum = solve_for(input, "x") + solve_for(input, "y")
    # res = solve_for(input, "z")
    # print = fn n -> n |> Integer.to_string(2) |> String.pad_leading(64, "0") |> IO.puts() end
    # Bitwise.bxor(sum, res) |> print.()
    # ""
  end

end
