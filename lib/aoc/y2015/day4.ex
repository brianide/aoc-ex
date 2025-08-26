defmodule AOC.Y2015.Day4 do
  @moduledoc title: "The Ideal Stocking Stuffer"
  @moduledoc url: "https://adventofcode.com/2015/day/4"

  use AOC.Solvers.Double, [2015, 4, &parse/1, &solve/1]

  def parse(input), do: input

  defp hash_md5(str), do: :crypto.hash(:md5, str) |> Base.encode16()

  def solve(input) do
    Stream.iterate(1, &(&1 + 1))
    |> Stream.map(fn n -> {n, hash_md5("#{input}#{n}")} end)
    |> Enum.reduce_while({nil, nil}, fn
      _, {a, b} when not is_nil(a) and not is_nil(b) -> {:halt, {a, b}}
      {n, s}, {nil, b} -> if String.starts_with?(s, "00000"), do: {:cont, {n, b}}, else: {:cont, {nil, b}}
      {n, s}, {a, nil} -> if String.starts_with?(s, "000000"), do: {:cont, {a, n}}, else: {:cont, {a, nil}}
      _, acc -> {:cont, acc}
    end)
  end

end
