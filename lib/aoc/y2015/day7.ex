defmodule AOC.Y2015.Day7 do
  @moduledoc title: "Some Assembly Required"
  @moduledoc url: "https://adventofcode.com/2015/day/7"

  use AOC.Solvers.Chain, [2015, 7, &parse/1, &silver/1, &gold/1]

  alias Bitwise, as: Bit

  def parse_term(term) do
    case Integer.parse(term) do
      {n, _} -> {:const, n}
      :error -> {:symbol, term}
    end
  end

  def parse(input) do
    for line <- String.splitter(input, "\n"),
        tokens = Regex.scan(~r/\w+/, line, capture: :first),
        tokens = Enum.map(tokens, &List.first/1) do
          case tokens do
            [a, r] -> {r, {:assign, parse_term(a)}}
            [a, "AND", b, r] -> {r, {:and, parse_term(a), parse_term(b)}}
            [a, "OR", b, r] -> {r, {:or, parse_term(a), parse_term(b)}}
            [a, "LSHIFT", b, r] -> {r, {:lshift, parse_term(a), parse_term(b)}}
            [a, "RSHIFT", b, r] -> {r, {:rshift, parse_term(a), parse_term(b)}}
            ["NOT", a, r] -> {r, {:not, parse_term(a)}}
          end
        end
        |> Map.new()
  end

  def simplify({:symbol, term}, table) do
    case Process.get(term) do
      nil ->
        res = simplify(table[term], table)
        Process.put(term, res)
        res
      v -> v
    end
  end

  def simplify({:const, n}, _), do: n
  def simplify({:assign, a}, table), do: simplify(a, table)
  def simplify({:and, a, b}, table), do: Bit.band(simplify(a, table), simplify(b, table))
  def simplify({:or, a, b}, table), do: Bit.bor(simplify(a, table), simplify(b, table))
  def simplify({:lshift, a, b}, table), do: Bit.bsl(simplify(a, table), simplify(b, table))
  def simplify({:rshift, a, b}, table), do: Bit.bsr(simplify(a, table), simplify(b, table))
  def simplify({:not, a}, table), do: Bit.bnot(simplify(a, table))

  def silver(table), do: simplify({:symbol, "a"}, table)

  def gold(_input) do
    "Not implemented"
  end

end
