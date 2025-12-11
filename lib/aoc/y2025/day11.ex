defmodule AOC.Y2025.Day11 do
  use AOC.Solution,
    title: "Reactor",
    url: "https://adventofcode.com/2025/day/11",
    scheme: {:shared, &parse/1, &solve(&1, "you"), &solve(&1, "svr", true)},
    newline: :preserve,
    complete: true

  def skip_char(<<_, rest::binary>>), do: rest

  def read_label(<<label::binary-size(3), rest::binary>>), do: {label, rest}

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

  def dfs(curr, map, gold, mem \\ %{}, seen \\ MapSet.new()) do
    {key, pass} =
      if gold do
        has_dac = MapSet.member?(seen, "dac")
        has_fft = MapSet.member?(seen, "fft")
        {{curr, has_dac, has_fft}, has_dac and has_fft}
      else
        {curr, true}
      end

    cond do
      MapSet.member?(seen, curr) ->
        {0, mem}

      is_map_key(mem, key) ->
        {mem[key], mem}

      curr === "out" and pass ->
        {1, mem}

      :else ->
        seen = MapSet.put(seen, curr)

        for neigh <- Map.get(map, curr, []), reduce: {0, mem} do
          {total, mem} ->
            {res, mem} = dfs(neigh, map, gold, mem, seen)
            {total + res, mem}
        end
        |> case do
          {res, mem} -> {res, put_in(mem[key], res)}
        end
    end
  end

  def solve(input, start, gold \\ false) do
    dfs(start, input, gold) |> elem(0)
  end
end
