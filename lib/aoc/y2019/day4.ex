defmodule AOC.Y2019.Day4 do
  use AOC.Solution,
    title: "Secure Container",
    url: "https://adventofcode.com/2019/day/4",
    scheme: {:once, &parse/1, &solve/1},
    complete: true

  require AOC.Read

  def parse(input) do
    [[lo, hi]] = AOC.Read.fscan("~d-~d", input)
    {lo, hi}
  end

  def mangle(pass) do
    digits = :math.log10(pass + 1) |> ceil()
    Stream.unfold(pass, fn
      n -> {rem(n, 10), div(n, 10)}
    end)
    |> Enum.take(digits)
  end

  def decreasing?([_]), do: true
  def decreasing?([a, b | rest]) when a >= b, do: decreasing?([b | rest])
  def decreasing?(_), do: false

  def has_double?([]), do: false
  def has_double?([_]), do: false
  def has_double?([a, b | _]) when a == b, do: true
  def has_double?([_ | rest]), do: has_double?(rest)

  def has_exclusive_double?(p), do: Stream.chunk_by(p, &(&1)) |> Enum.any?(&(length(&1) == 2))

  def solve({lo, hi}) do
    for p <- lo..hi,
        p = mangle(p),
        decreasing?(p),
        ps = has_double?(p) && 1 || 0,
        ps == 1,
        pg = has_exclusive_double?(p) && 1 || 0,
        reduce: {0, 0},
        do: ({s, g} -> {s + ps, g + pg})
  end

end
