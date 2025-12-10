defmodule AOC.Y2025.Day9 do
  import AOC.Read, only: [fscan: 2]

  use AOC.Solution,
    title: "Movie Theater",
    url: "https://adventofcode.com/2025/day/9",
    scheme: {:chain, &parse/1, &silver/1, &gold/2},
    complete: true

  def parse(input) do
    for [x, y] <- fscan("~d,~d\n", input), p = {x, y}, reduce: nil do
      nil ->
        {[p], [], [], p}

      {[prev | _] = list, segs, combs, first} ->
        combs = for(b <- list, do: {p, b}) ++ combs
        list = [p | list]
        segs = [{p, prev} | segs]
        {list, segs, combs, first}
    end
    |> case do
      {[last | _], segs, combs, first} ->
        segs = [{first, last} | segs]
        {segs, combs}
    end
  end

  def area({{x, y}, {i, j}}), do: (abs(i - x) + 1) * (abs(j - y) + 1)

  def silver({_segs, combs}) do
    combs = Enum.sort_by(combs, &area/1, :desc)

    # Reuse area-sorted point combinations in part 2
    {area(hd(combs)), combs}
  end

  def dist({{x, y}, {i, j}}), do: max(abs(i - x), abs(j - y))

  def normalize({{x1, y1}, {x2, y2}}) do
    {{min(x1, x2), min(y1, y2)}, {max(x1, x2), max(y1, y2)}}
  end

  def intersects?(p1, p2) do
    {{x1min, y1min}, {x1max, y1max}} = normalize(p1)
    {{x2min, y2min}, {x2max, y2max}} = normalize(p2)
    x1min < x2max and x1max > x2min and y1min < y2max and y1max > y2min
  end

  def gold({segs, _}, combs) do
    segs = segs |> Enum.sort_by(&dist/1, :desc)

    Enum.find(combs, fn comb -> Enum.all?(segs, fn seg -> not intersects?(comb, seg) end) end)
    |> area()
  end
end
