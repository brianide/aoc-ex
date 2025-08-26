defmodule AOC.Y2015.Day7 do
  @moduledoc title: "Some Assembly Required"
  @moduledoc url: "https://adventofcode.com/2015/day/7"

  use AOC.Solvers.Double, [2015, 7, &parse/1, &solve/1]

  alias Bitwise, as: Bit

  def parse_term(term) do
    case Integer.parse(term) do
      {n, _} -> {:const, n}
      :error -> {:symbol, term}
    end
  end

  def parse(input) do
    for line <- String.splitter(input, "\n", trim: true),
        tokens = Regex.scan(~r/\w+/, line, capture: :first),
        tokens = Enum.map(tokens, &List.first/1) do
          case tokens do
            [a, r] -> {r, {:una, &Function.identity/1, parse_term(a)}}
            [a, "AND", b, r] -> {r, {:bin, &Bit.band/2, parse_term(a), parse_term(b)}}
            [a, "OR", b, r] -> {r, {:bin, &Bit.bor/2, parse_term(a), parse_term(b)}}
            [a, "LSHIFT", b, r] -> {r, {:bin, &Bit.bsl/2, parse_term(a), parse_term(b)}}
            [a, "RSHIFT", b, r] -> {r, {:bin, &Bit.bsr/2, parse_term(a), parse_term(b)}}
            ["NOT", a, r] -> {r, {:una, &Bit.bnot/1, parse_term(a)}}
          end
        end
        |> Map.new()
  end

  def simplify(table) do
    simplify({:symbol, "a"}, table, %{})
    |> then(&elem(&1, 0))
  end

  def simplify({:const, n}, _, mem), do: {n, mem}

  def simplify({:symbol, term}, table, mem) do
    if is_map_key(mem, term) do
      {mem[term], mem}
    else
      {res, mem} = simplify(table[term], table, mem)
      {res, put_in(mem[term], res)}
    end
  end

  def simplify({:una, op, a}, table, mem) do
    {n, mem} = simplify(a, table, mem)
    {op.(n), mem}
  end

  def simplify({:bin, op, a, b}, table, mem) do
    {a, mem} = simplify(a, table, mem)
    {b, mem} = simplify(b, table, mem)
    {op.(a, b), mem}
  end

  def solve(table) do
    silv = simplify(table)
    gold = simplify(put_in(table["b"], {:const, silv}))
    {silv, gold}
  end

end
