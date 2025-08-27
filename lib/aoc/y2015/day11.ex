defmodule AOC.Y2015.Day11 do
  use AOC.Solution,
    title: "Corporate Policy",
    url: "https://adventofcode.com/2015/day/11",
    scheme: {:chain, &parse/1, &silver/1, &gold/2},
    complete: true,
    favorite: true

  @doc "Converts the password into a list of offsets from `?a`"
  def parse(input) do
    for(ch <- String.to_charlist(input), do: ch - ?a)
    |> Enum.reverse()
  end

  @doc "Advances to the next potential password, rolling over digits"
  def increment([25 | rest]), do: [0 | increment(rest)]
  def increment([n | rest]), do: [n + 1 | rest]
  def increment([]), do: []

  @doc "Verifies an ascending straight is present"
  def rule1?([]), do: false
  def rule1?([a, b, c | _]) when a - b == 1 and b - c == 1, do: true
  def rule1?([_ | rest]), do: rule1?(rest)

  @doc "Verifies two pairs are present"
  def rule3?(pass, found \\ 0)
  def rule3?(_pass, 2), do: true
  def rule3?([], _found), do: false
  def rule3?([a, b | rest], found) when a == b, do: rule3?(rest, found + 1)
  def rule3?([_ | rest], found), do: rule3?(rest, found)

  @doc "Pads the head of the list to the specified length"
  def pad_list(list, _fill, 0), do: list
  def pad_list(list, fill, count), do: pad_list([fill | list], fill, count - 1)

  @banned Enum.map(~c"iol", &(&1 - ?a))

  @doc "Returns the next password that does not violate rule 2"
  def check_banned(pass) do
    case check_banned(pass, 0) do
      :ok -> pass
      {:replace, p} -> p
    end
  end

  def check_banned([], _depth), do: :ok

  def check_banned([h | rest], depth) when h in @banned,
    do: {:replace, [h + 1 | rest] |> pad_list(0, depth)}

  def check_banned([_ | rest], depth), do: check_banned(rest, depth + 1)

  @doc "Returns the next fully valid password"
  def next_pass(pass) do
    pass = increment(pass) |> check_banned()
    if rule1?(pass) and rule3?(pass), do: pass, else: next_pass(pass)
  end

  @doc "Converts the password from offsets back to a printable string"
  def unmangle(pass), do: Enum.reverse(pass) |> Enum.map(&(&1 + ?a)) |> List.to_string()

  def silver(input), do: next_pass(input) |> case(do: (n -> {unmangle(n), n}))

  def gold(_input, prev), do: next_pass(prev) |> unmangle()
end
