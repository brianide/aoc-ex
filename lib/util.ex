defmodule AOC.Util do

  def sign(x) when x > 0, do: 1
  def sign(x) when x < 0, do: -1
  def sign(_), do: 0

  def parse_grid(str, opts) do
    opts = Keyword.validate!(opts, ignore: ["."], dims: true)

    str
    |> String.trim()
    |> String.graphemes()
    |> Stream.concat([:eof])
    |> Enum.reduce({%{}, 0, 0, 0}, fn
      "\n", {chars, r, c, _} -> {chars, r + 1, 0, c}
      :eof, {chars, r, _, wd} -> if not opts[:dims], do: chars, else: {chars, r, wd}
      ch, {chars, r, c, wd} -> {(if ch in opts[:ignore], do: chars, else: Map.update(chars, ch, [{r, c}], &[{r, c} | &1])), r, c + 1, wd}
    end)
  end

end
