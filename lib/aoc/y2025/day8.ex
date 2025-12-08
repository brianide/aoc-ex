defmodule AOC.Y2025.Day8 do
  import AOC.Read, only: [fscan: 2]

  use AOC.Solution,
    title: "Playground",
    url: "https://adventofcode.com/2025/day/8",
    scheme: {:chain, &parse/1, &silver/1, &gold/2},
    complete: true,
    tags: [:spatial]

  def parse(input) do
    for [x, y, z] <- fscan("~d,~d,~d\n", input) do
      {x, y, z}
    end
  end

  def dist_sq({{x, y, z}, {i, j, k}}) do
    (i - x) ** 2 + (j - y) ** 2 + (k - z) ** 2
  end

  def combinations(acc \\ [], list)
  def combinations(acc, [_]), do: Enum.concat(acc)

  def combinations(acc, [a | rest]) do
    res = for(b <- rest, do: {a, b})
    combinations([res | acc], rest)
  end

  def build_circuits(circs \\ MapSet.new(), pairs, prev \\ nil, left, unconn)
  def build_circuits(circs, pairs, _prev, 0, unconn), do: {circs, pairs, unconn}

  def build_circuits(circs, [{a, b} = pair | pairs], prev, left, unconn) do
    if unconn === 0 and MapSet.size(circs) === 1 do
      prev
    else
      circuit = fn p -> Enum.find(circs, nil, &MapSet.member?(&1, p)) end
      a_circ = circuit.(a)
      b_circ = circuit.(b)

      case {a_circ, b_circ} do
        {nil, nil} ->
          MapSet.put(circs, MapSet.new([a, b]))
          |> build_circuits(pairs, pair, left - 1, unconn - 2)

        {^b_circ, ^a_circ} ->
          build_circuits(circs, pairs, nil, left - 1, unconn)

        {_, nil} ->
          circs
          |> MapSet.delete(a_circ)
          |> MapSet.put(MapSet.put(a_circ, b))
          |> build_circuits(pairs, pair, left - 1, unconn - 1)

        {nil, _} ->
          circs
          |> MapSet.delete(b_circ)
          |> MapSet.put(MapSet.put(b_circ, a))
          |> build_circuits(pairs, pair, left - 1, unconn - 1)

        _ ->
          circs
          |> MapSet.delete(a_circ)
          |> MapSet.delete(b_circ)
          |> MapSet.put(MapSet.union(a_circ, b_circ))
          |> build_circuits(pairs, pair, left - 1, unconn)
      end
    end
  end

  def silver(input) do
    size = length(input)
    state = input |> combinations() |> Enum.sort_by(&dist_sq/1) |> build_circuits(1000, size)

    elem(state, 0)
    |> Stream.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Stream.take(3)
    |> Enum.reduce(&Kernel.*/2)
    |> case do
      res -> {res, state}
    end
  end

  def gold(_input, {circs, pairs, unconn}) do
    {{x, _, _}, {i, _, _}} = build_circuits(circs, pairs, -1, unconn)
    x * i
  end
end
