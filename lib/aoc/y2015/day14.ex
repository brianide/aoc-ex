defmodule AOC.Y2015.Day14 do
  use AOC.Solution,
    title: "Reindeer Olympics",
    url: "https://adventofcode.com/2015/day/14",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: true

  import AOC.Read, only: [fscan: 2]

  @format "~s can fly ~d km/s for ~d seconds, but then must rest for ~d seconds."
  def parse(input) do
    for [deer, speed, time, rest] <- fscan(@format, input),
        reduce: %{} do acc ->
          put_in(acc[deer], %{speed: speed, uptime: time, downtime: rest, cycle_time: time + rest})
        end
  end

  def distance_at(deer, time) do
    cycles_completed = div(time, deer.cycle_time)
    dist_per_cycle = deer.uptime * deer.speed

    leftover_seconds = rem(time, deer.cycle_time)
    dist_in_last_cycle = deer.speed * min(leftover_seconds, deer.uptime)

    dist_per_cycle * cycles_completed + dist_in_last_cycle
  end

  def silver(input) do
    Map.values(input)
    |> Stream.map(&distance_at(&1, 2503))
    |> Enum.max()
  end

  def simulate(deer, limit, time \\ 0, dist \\ %{}, scores \\ %{})

  def simulate(_deer, limit, time, _dist, scores) when time > limit do
    Map.values(scores) |> Enum.max()
  end

  def simulate(deer, limit, time, dist, scores) do
    dist =
      Map.new(deer, fn {k, deer} ->
        running = rem(time, deer.cycle_time) < deer.uptime
        dist = Map.get(dist, k, 0) + (if running, do: deer.speed, else: 0)
        {k, dist}
      end)

    max_dist = Map.values(dist) |> Enum.max()
    scores =
      Map.new(dist, fn
        {k, dist} when dist == max_dist -> {k, Map.get(scores, k, 0) + 1}
        {k, _dist} -> {k, Map.get(scores, k, 0)}
      end)

    simulate(deer, limit, time + 1, dist, scores)
  end

  def gold(input) do
    simulate(input, 2503)
  end

end
