defmodule AOC.Y2024.Day20 do
  @moduledoc title: "Race Condition"
  @moduledoc url: "https://adventofcode.com/2024/day/20"

  def solver, do: AOC.Scaffold.double_solver(2024, 20, &parse/1, &solve/1)

  def parse(input) do
    case AOC.Util.parse_grid(input, dims: false, ignore: [?#], as_strings: false) do
      %{?. => f, ?S => [s], ?E => [e]} ->
        {MapSet.new([s, e | f]), s}
    end
  end

  defp walk(tiles, {r, c}, func, prev \\ nil, depth \\ 1) do
    func.({:node, {r, c}, depth})
    for {dr, dc} <- [{0, 1}, {0, -1}, {1, 0}, {-1, 0}],
        r = r + dr,
        c = c + dc,
        {r, c} !== prev,
        {r, c} in tiles do
          {r, c}
        end
    |> case do
      [next] -> walk(tiles, next, func, {r, c}, depth + 1)
      [] -> func.(:done)
    end
  end

  defp manhattan_dist({ra, ca}, {rb, cb}), do: abs(rb - ra) + abs(cb - ca)

  @threshold 100
  defp check_skips(parent, totals \\ {0, 0}, prevs \\ []) do
    receive do
      :done -> send(parent, totals)
      {:node, pos, dist} ->
        for {posb, distb} <- Enum.drop(prevs, 100),
            nanos = manhattan_dist(pos, posb),
            nanos <= 20,
            dist - distb - nanos >= @threshold,
            reduce: totals do
              {s, g} when nanos === 2 -> {s + 1, g + 1}
              {s, g} -> {s, g + 1}
            end
        |> case do totals -> check_skips(parent, totals, [{pos, dist} | prevs]) end
    end
  end

  def solve({tiles, start}) do
    parent = self()
    pid = spawn(fn -> check_skips(parent) end)

    walk(tiles, start, &send(pid, &1))
    receive do
      totals -> totals
    end
  end

end
