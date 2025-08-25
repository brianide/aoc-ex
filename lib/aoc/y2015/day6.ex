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

  def silver(input) do
    for {act, {r1, c1}, {r2, c2}} <- input,
        r <- r1..r2,
        c <- c1..c2,
        key = r * 999 + c,
        reduce: Arrays.new(Stream.duplicate(false, 999 * 999)) do acc ->
          case act do
            :on -> put_in(acc[key], true)
            :off -> put_in(acc[key], false)
            :toggle -> update_in(acc[key], &(not &1))
          end
        end
    |> Enum.count(fn n -> n end)
  end

  def gold(input) do
    "Not implemented"
  end

end
