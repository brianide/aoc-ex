defmodule AOC.Y2015.Day6 do

  use AOC.Solution,
    title: "Probably a Fire Hazard",
    url: "https://adventofcode.com/2015/day/6",
    scheme: {:shared, &parse/1, &silver/1, &gold/1}

  import AOC.Util.Guards

  @size 1000

  @regex ~r/(turn (?:on|off)|toggle) (\d+,\d+) through (\d+,\d+)/
  def parse(input) do
    for [act, p1, p2] <- AOC.Util.Regex.scan_typed(@regex, [:str, :point, :point], input),
        act = (case act, do: ("turn on" -> :on; "turn off" -> :off; "toggle" -> :toggle)) do
      {act, p1, p2}
    end
  end

  def solve_parallel(input, chunk_fn) do
    tasks = System.schedulers_online()
    per = ceil(@size / tasks)
    Task.async_stream(0..(tasks - 1), fn n ->
      s = n * per
      f = (n + 1) * per - 1 |> min(@size - 1)
      for r <- s..f,
          c <- 0..(@size - 1),
          p = {r, c},
          reduce: 0 do acc ->
            chunk_fn.(input, p)
            |> case do n -> acc + n end
          end
    end)
    |> Enum.reduce(0, fn
      {:ok, n}, acc -> acc + n
    end)
  end

  def silver(input) do
    solve_parallel(Enum.reverse(input), fn input, p ->
      Enum.reduce_while(input, 0, fn
        {:toggle, b1, b2}, flip when is_contained(p, b1, b2) -> {:cont, 1 - flip}
        {:on, b1, b2}, flip when is_contained(p, b1, b2) -> {:halt, 1 - flip}
        {:off, b1, b2}, flip when is_contained(p, b1, b2) -> {:halt, flip}
        _, flip -> {:cont, flip}
      end)
    end)
  end

  def gold(input) do
    solve_parallel(input, fn input, p ->
      Enum.reduce(input, 0, fn
        {:toggle, b1, b2}, n when is_contained(p, b1, b2) -> n + 2
        {:on, b1, b2}, n when is_contained(p, b1, b2) -> n + 1
        {:off, b1, b2}, n when is_contained(p, b1, b2) and n > 0 -> n - 1
        _, n -> n
      end)
    end)
  end

end
