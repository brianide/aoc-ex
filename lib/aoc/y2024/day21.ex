defmodule AOC.Y2024.Day21 do

  use AOC.Solution,
    title: "Keypad Conundrum",
    url: "https://adventofcode.com/2024/day/21",
    scheme: {:shared, &parse/1, &silver/1, &gold/1}

  defmodule Grids do
    import AOC.Sigils

    @keypad ~g"""
              789
              456
              123
              #0A
              """

    @panel ~g"""
             #^A
             <v>
             """

    def keypad, do: @keypad
    def panel, do: @panel

    def for_depth(0), do: keypad()
    def for_depth(_), do: panel();

    def offset("<"), do: {0, -1}
    def offset(">"), do: {0, 1}
    def offset("^"), do: {-1, 0}
    def offset("v"), do: {1, 0}
    def offset("A"), do: {0, 0}
  end

  def parse(input) do
    for s <- String.split(input, "\n"),
        score = String.slice(s, 0..2) |> String.to_integer(),
        digits = String.graphemes(s),
        do: {digits, score}
  end

  defp diff({r, c}, {br, bc}), do: {r - br, c - bc}
  defp add({r, c}, {br, bc}), do: {r + br, c + bc}

  defp combos(a, b, prefix \\ ["A"])
  defp combos([], [], prefix), do: [prefix]
  defp combos([], b, prefix), do: [b ++ prefix]
  defp combos(a, [], prefix), do: combos([], a, prefix)
  defp combos([ha | resta], [hb | restb], prefix) do
    [
      combos(resta, [hb | restb], [ha | prefix]),
      combos([ha | resta], restb, [hb | prefix]),
    ]
    |> Stream.concat()
  end

  defp check_path(pos, path, depth) do
    dud = Map.get(Grids.for_depth(depth), "#")

    Stream.map(path, &Grids.offset/1)
    |> Stream.scan(pos, &add/2)
    |> Enum.all?(&(&1 !== dud))
  end

  defp paths(src, dst, depth) do
    grid = Grids.for_depth(depth)
    src_pos = Map.get(grid, src)
    dst_pos = Map.get(grid, dst)
    {dr, dc} = diff(dst_pos, src_pos)

    moves =
      fn d, inc, dec ->
        (if d > 0, do: inc, else: dec)
        |> Stream.duplicate(abs(d))
        |> Enum.to_list()
      end

    combos(moves.(dr, "v", "^"), moves.(dc, ">", "<"))
    |> Enum.filter(&check_path(src_pos, &1, depth))
  end

  defp shortest(src, dst, depth) do
    paths(src, dst, depth)
    |> Enum.sort_by(&length/1, :asc)
    |> List.first()
  end

  defp expand(code, level, max_level) when level === max_level, do: code
  defp expand(code, level, max_level) do
    AOC.Util.pairwise(["A" | code])
    |> Enum.flat_map(fn {a, b} -> shortest(a, b, level) end)
    |> expand(level + 1, max_level)
  end

  def silver(input) do
    for {code, mult} <- input,
        code = expand(code, 0, 3) do
          Enum.join(code) |> IO.puts()
          {length(code), mult}
        end
    |> inspect()
  end

  def gold(_input) do
    "Not implemented"
  end

end
