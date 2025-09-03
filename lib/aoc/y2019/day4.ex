defmodule AOC.Y2019.Day4 do
  use AOC.Solution,
    title: "Secure Container",
    url: "https://adventofcode.com/2019/day/4",
    scheme: {:once, &parse/1, &solve/1},
    complete: true

  alias AOC.Util.Zipper.ListZipper, as: Zip
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
    |> Enum.reverse()
    |> Zip.from_list()
  end

  def normalize({_, _, []} = pass), do: Zip.front(pass)
  def normalize({n, _, [r | _]} = pass) when n > r, do: Zip.right(pass) |> Zip.replace(n) |> normalize()
  def normalize(pass), do: Zip.right(pass) |> normalize()

  def next_pass(p) do
    Zip.back(p)
    |> Zip.reverse()
    |> increment_pass()
    |> propogate_pass()
    |> Zip.back()
    |> Zip.reverse()
  end

  def increment_pass({9, _, _} = pass), do: Zip.replace(pass, 0) |> Zip.right() |> increment_pass()
  def increment_pass({n, _, _} = pass), do: Zip.replace(pass, n + 1)

  def propogate_pass({_, [], _} = pass), do: pass
  def propogate_pass({n, _, _} = pass), do: Zip.left(pass) |> Zip.replace(n) |> propogate_pass()

  def has_double?({_, _, []}), do: false
  def has_double?({foc, _, [r | _]}) when foc == r, do: true
  def has_double?(pass), do: Zip.right(pass) |> has_double?()

  def has_exclusive_double?(pass) do
    Zip.to_list(pass)
    |> Stream.chunk_by(&(&1))
    |> Enum.any?(&(length(&1) == 2))
  end

  def solve({lo, hi}) do
    lim = mangle(hi)

    for p <- mangle(lo) |> normalize() |> Stream.iterate(&next_pass/1) |> Stream.take_while(&(&1 < lim)),
        ps = has_double?(p) && 1 || 0,
        ps == 1,
        pg = has_exclusive_double?(p) && 1 || 0,
        reduce: {0, 0},
        do: ({s, g} -> {s + ps, g + pg})
  end
end
