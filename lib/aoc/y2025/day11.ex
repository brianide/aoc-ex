defmodule AOC.Y2025.Day11 do
  use AOC.Solution,
    title: "Reactor",
    url: "https://adventofcode.com/2025/day/11",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    newline: :preserve,
    complete: false

  def skip_char(<<_, rest::binary>>), do: rest

  def read_label(<<label::binary-size(3), rest::binary>>), do: {label, rest}

  @spec read_outputs(any(), any(), nonempty_binary()) :: {any(), binary()}
  def read_outputs(acc, dev, bin) do
    case bin do
      <<?\n, rest::binary>> ->
        {acc, rest}
      <<?\s, rest::binary>> ->
        {out, rest} = read_label(rest)
        Map.update(acc, dev, [out], &[out | &1])
        |> read_outputs(dev, rest)
    end
  end

  def parse(acc \\ %{}, bin) do
    case bin do
      <<>> ->
        acc
      bin ->
        {dev, rest} = read_label(bin)
        {acc, rest} = read_outputs(acc, dev, skip_char(rest))
        parse(acc, rest)
    end
  end

  def dfs(curr, map, seen \\ MapSet.new()) do
    cond do
      curr === "out" ->
        1
      MapSet.member?(seen, curr) ->
        0
      :else ->
        MapSet.put(seen, curr)
        for neigh <- Map.get(map, curr, []), reduce: 0 do
          acc -> acc + dfs(neigh, map, seen)
        end
    end
  end

  def silver(input) do
    dfs("you", input)
  end

  def gold(_input) do
    "Not implemented"
  end

end
