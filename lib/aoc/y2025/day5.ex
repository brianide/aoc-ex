defmodule AOC.Y2025.Day5 do
  import AOC.Read, only: [fscan: 2]

  use AOC.Solution,
    title: "Cafeteria",
    url: "https://adventofcode.com/2025/day/5",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    complete: true,
    tags: [:easy, :merge_intervals]

  def parse(input) do
    [fresh, avail] = String.split(input, "\n\n")
    fresh = for [lo, hi] <- fscan("~d-~d\n", fresh), do: {lo, hi}
    avail = for [id] <- fscan("~d\n", avail), do: id
    {Enum.sort(fresh), Enum.sort(avail)}
  end

  def count_fresh(fresh, avail, total \\ 0)
  def count_fresh([], _, total), do: total
  def count_fresh(_, [], total), do: total

  def count_fresh([{lo, hi} | f_rest] = fresh, [a_head | a_rest] = avail, total) do
    cond do
      a_head > hi -> count_fresh(f_rest, avail, total)
      a_head < lo -> count_fresh(fresh, a_rest, total)
      :else -> count_fresh(fresh, a_rest, total + 1)
    end
  end

  def silver({fresh, avail}), do: count_fresh(fresh, avail)

  def gold({fresh, _avail}) do
    add_range = fn {{lo, hi}, acc} -> acc + hi - lo + 1 end

    Enum.reduce(fresh, nil, fn
      range, nil -> {range, 0}
      {lo, hi}, {{plo, phi}, total} when phi >= lo -> {{plo, max(hi, phi)}, total}
      range, acc -> {range, add_range.(acc)}
    end)
    |> then(add_range)
  end
end
