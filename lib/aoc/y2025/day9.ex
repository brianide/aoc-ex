defmodule AOC.Y2025.Day9 do
  import AOC.Read, only: [fscan: 2]

  use AOC.Solution,
    title: "Movie Theater",
    url: "https://adventofcode.com/2025/day/9",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: false

  def parse(input) do
    for [x, y] <- fscan("~d,~d\n", input),
        p = {x, y},
        reduce: nil do
      nil ->
        {[p], [], []}
      {[prev | _] = list, segs, combs} ->
        combs = for(b <- list, do: {p, b}) ++ combs
        list = [p | list]
        segs = [{p, prev} | segs]
        {list, segs, combs}
    end
    |> Tuple.delete_at(0)
  end

  def area({{x, y}, {i, j}}), do: (abs(i - x) + 1) * (abs(j - y) + 1)

  def silver({_segs, combs}) do
    for comb <- combs, reduce: -1 do
      acc -> max(acc, area(comb))
    end
  end

  def dist({{x, y}, {i, j}}), do: max(abs(i - x), abs(j - y))

  def gold({segs, combs}) do
    segs = segs |> Enum.sort_by(&dist/1, :desc)
    # |> inspect(charlists: :as_lists)
    "Not implemented"
  end

end
