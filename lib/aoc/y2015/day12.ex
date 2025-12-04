defmodule AOC.Y2015.Day12 do
  use AOC.Solution,
    title: "JSAbacusFramework.io",
    url: "https://adventofcode.com/2015/day/12",
    scheme: {:separate, &silver/1, &gold/1},
    complete: true

  def silver(input) do
    for [s] <- Regex.scan(~r/-?\d+/, input), reduce: 0, do: (acc -> acc + String.to_integer(s))
  end

  def gold(input) do
    AOC.Y2015.Day12.JSON.parse(input)
  end
end

defmodule AOC.Y2015.Day12.JSON do
  @regex ~r<[][}{]|"[^"]+"|-?\d+>
  def tokenize(str), do: for([s] <- Regex.scan(@regex, str), do: s)

  def parse_value(["{" | rest]), do: parse_object(rest)
  def parse_value(["[" | rest]), do: parse_array(rest)

  def parse_value([str | rest]) do
    case Integer.parse(str) do
      {n, _} -> {n, rest}
      :error -> {String.slice(str, 1, String.length(str) - 2), rest}
    end
  end

  def parse_object(tokens, total \\ 0, red \\ false)
  def parse_object(["}" | rest], total, false), do: {total, rest}
  def parse_object(["}" | rest], _total, true), do: {0, rest}

  def parse_object(tokens, total, red) do
    {_key, tokens} = parse_value(tokens)
    case parse_value(tokens) do
      {"red", tokens} -> parse_object(tokens, total, true)
      {n, tokens} when is_number(n) -> parse_object(tokens, total + n, red)
      {_, tokens} -> parse_object(tokens, total, red)
    end
  end

  def parse_array(tokens, total \\ 0)
  def parse_array(["]" | rest], total), do: {total, rest}

  def parse_array(tokens, total) do
    case parse_value(tokens) do
      {n, tokens} when is_number(n) -> parse_array(tokens, total + n)
      {_, tokens} -> parse_array(tokens, total)
    end
  end

  def parse(str), do: tokenize(str) |> parse_value() |> then(&elem(&1, 0))

end
