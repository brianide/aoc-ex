defmodule AOC.Y2015.Day7 do

  use AOC.Solution,
    title: "Some Assembly Required",
    url: "https://adventofcode.com/2015/day/7",
    scheme: {:chain, &parse/1, &silver/1, &gold/2},
    complete: true,
    favorite: true

  use AOC.Solvers.AndThen, [2015, 7, &parse/1, &silver/1, &gold/2]
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

  def simplify({:const, n}, _table, mem), do: {n, mem}

  def simplify({:symbol, term}, _table, mem) when is_map_key(mem, term), do: {mem[term], mem}

  def simplify({:symbol, term}, table, mem) do
    {res, mem} = simplify(table[term], table, mem)
    {res, put_in(mem[term], res)}
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

  def silver(table) do
    res = simplify(table)
    {res, res}
  end

  def gold(table, silv), do: simplify(put_in(table["b"], {:const, silv}))

end
