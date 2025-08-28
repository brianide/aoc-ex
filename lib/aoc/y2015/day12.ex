defmodule AOC.Y2015.Day12.JSON do
  @regex ~r<[][}{]|"[^"]+"|-?\d+>
  def tokenize(str), do: for [s] <- Regex.scan(@regex, str), do: s

  def parse_value(["{" | rest]), do: parse_object(rest)
  def parse_value(["[" | rest]), do: parse_array(rest)

  def parse_value([str | rest]) do
    case Integer.parse(str) do
      {n, _} -> {n, rest}
      :error -> {String.slice(str, 1, String.length(str) - 2), rest}
    end
  end

  def parse_object(tokens, values \\ [])
  def parse_object(["}" | rest], values), do: {{:object, values}, rest}

  def parse_object(tokens, values) do
    {_key, tokens} = parse_value(tokens)
    {val, tokens} = parse_value(tokens)
    parse_object(tokens, [val | values])
  end

  def parse_array(tokens, values \\ [])
  def parse_array(["]" | rest], values), do: {{:array, values}, rest}

  def parse_array(tokens, values) do
    {val, tokens} = parse_value(tokens)
    parse_array(tokens, [val | values])
  end

  def parse(str), do: tokenize(str) |> parse_value()

end

defmodule AOC.Y2015.Day12 do
  use AOC.Solution,
    title: "JSAbacusFramework.io",
    url: "https://adventofcode.com/2015/day/12",
    scheme: {:separate, &silver/1, &gold/1},
    complete: false

  def silver(input) do
    for [s] <- Regex.scan(~r/-?\d+/, input), reduce: 0, do: (acc -> acc + String.to_integer(s))
  end

  def gold(input) do

  end

  def test(s), do: s |> silver() |> IO.puts()
end
