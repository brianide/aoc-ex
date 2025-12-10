defmodule AOC.Y2025.Day10 do
  alias PriorityQueue, as: PQ

  use AOC.Solution,
    title: "Factory",
    url: "https://adventofcode.com/2025/day/10",
    scheme: {:shared, &parse/1, &silver/1, &gold/1},
    newline: :preserve,
    complete: false

  ### PARSING

  def skip_char(<<_, rest::binary>>), do: rest

  def linefeed(<<?\n, rest::binary>>), do: rest
  def linefeed(<<_, rest::binary>>), do: linefeed(rest)

  def read_lights(lights \\ [], <<ch, rest::binary>>) do
    case ch do
      ?. -> [0 | lights] |> read_lights(rest)
      ?# -> [1 | lights] |> read_lights(rest)
      ?] -> {Enum.reverse(lights), skip_char(rest)}
    end
  end

  def read_number(val \\ 0, <<ch, rest::binary>> = bin) do
    cond do
      ch in ?0..?9 -> val * 10 + ch - ?0 |> read_number(rest)
      :else -> {val, bin}
    end
  end

  def read_buttons(buttons \\ [], <<ch, rest::binary>> = bin) do
    case ch do
      ?( ->
        {button, rest} = read_button(bin)
        [button | buttons] |> read_buttons(rest)
      ?{ ->
        {buttons, linefeed(rest)}
    end
  end

  def read_button(toggles \\ [], <<ch, rest::binary>>) do
    case ch do
      ?) ->
        {Enum.reverse(toggles), skip_char(rest)}
      _ ->
        {val, rest} = read_number(rest)
        [val | toggles] |> read_button(rest)
    end
  end

  def read_configs(configs \\ [], bin)
  def read_configs(configs, <<>>), do: Enum.reverse(configs)

  def read_configs(configs, bin) do
    {lights, rest} = skip_char(bin) |> read_lights()
    {buttons, rest} = read_buttons(rest)
    [{lights, buttons} | configs]
    |> read_configs(rest)
  end

  def parse(input), do: read_configs(input)

  ### SILVER

  def press_button(acc \\ [], ind \\ 0, state, toggles)
  def press_button(acc, _ind, state, []), do: Enum.reverse(acc) ++ state
  def press_button(acc, ind, [s | state], [t | toggles]) when ind === t, do: press_button([1 - s | acc], ind + 1, state, toggles)
  def press_button(acc, ind, [s | state], toggles), do: press_button([s | acc], ind + 1, state, toggles)

  def neighbors(state, buttons) do
    for button <- buttons, do: press_button(state, button)
  end

  def search(init, buttons), do: PQ.new() |> PQ.put(0, init) |> search(buttons, MapSet.new([init]))

  def search(queue, buttons, visited) do
    {{dist, next}, queue} = PQ.pop!(queue)
    if Enum.all?(next, &(&1 === 0)) do
      dist
    else
      dist = dist + 1
      for n <- neighbors(next, buttons),
          not MapSet.member?(visited, n),
          reduce: {queue, visited} do
        {queue, visited} ->
          queue = PQ.put(queue, dist, n)
          visited = MapSet.put(visited, n)
          {queue, visited}
      end
      |> case do
        {queue, visited} -> search(queue, buttons, visited)
      end
    end
  end

  def silver(input) do
    for {init, buttons} <- input, reduce: 0 do
      acc -> acc + search(init, buttons)
    end
  end

  def gold(_input) do
    "Not implemented"
  end

end
