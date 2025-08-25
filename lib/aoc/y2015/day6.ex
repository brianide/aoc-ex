defmodule AOC.Y2015.Day6 do
  @moduledoc title: "Probably a Fire Hazard"
  @moduledoc url: "https://adventofcode.com/2015/day/6"

  use AOC.Solvers.Chain, [2015, 6, &parse/1, &silver/1, &gold/1]

  @regex ~r/(turn on|turn off|toggle) (\d+,\d+) through (\d+,\d+)/
  def parse(input) do
    for [act, p1, p2] <- AOC.Util.Regex.scan_typed(@regex, [:str, :point, :point], input),
        act = (case act, do: ("turn on" -> :on; "turn off" -> :off; "toggle" -> :toggle)) do
      {act, p1, p2}
    end
  end

  defguardp between?(n, l, u) when l <= n and n <= u
  defguardp contained?(p, b1, b2) when between?(elem(p, 0), elem(b1, 0), elem(b2, 0)) and between?(elem(p, 1), elem(b1, 1), elem(b2, 1))

  @size 1000
  def silver(input) do
    input = Enum.reverse(input)
    for r <- 0..(@size - 1),
        c <- 0..(@size - 1),
        p = {r, c},
        reduce: 0 do acc ->
          Enum.reduce_while(input, 0, fn
            {:toggle, b1, b2}, flip when contained?(p, b1, b2) -> {:cont, 1 - flip}
            {:on, b1, b2}, flip when contained?(p, b1, b2) -> {:halt, 1 - flip}
            {:off, b1, b2}, flip when contained?(p, b1, b2) -> {:halt, flip}
            _, flip -> {:cont, flip}
          end)
          |> case do n -> acc + n end
        end
  end

  def gold(input) do
    "Not implemented"
  end

end
