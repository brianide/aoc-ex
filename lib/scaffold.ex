defmodule AOC.Scaffold do

  defp get_parts(input, parts, silver, gold) do
    case parts do
      s when s in ["s", "silver"] -> [:silver]
      s when s in ["g", "gold"] -> [:gold]
      s when s in ["b", "both"] -> [:silver, :gold]
    end
    |> Enum.map(&(case &1 do :silver -> silver.(input); :gold -> gold.(input) end))
  end

  # defp solver(year, day, mod, pre, silver, gold) do
  #   {:input, [], mod} ++ pre ++ [
  #     quote do get_parts(parts, unquote(silver), unquote(gold)) end,
  #     quote do Enum.join("\n") end
  #   ]
  #   |> Enum.reduce(&Macro.pipe(&1))

  #   quote do
  #     fn [parts, path] ->
  #       input = File.read!("#{path}/#{year}/day#{day}.txt") |> String.trim()

  #       :timer.tc(fn ->
  #         get_parts(input, parts, silver, gold)
  #         |> Enum.join("\n")
  #       end)
  #     end
  #   end
  # end

  # defmacro doubler_solver(year, day, parse, solve) do
  #   solver(year, day, __CALLER__, [parse, solve], &elem(&1, 0), &elem(&1, 1))
  # end

  @doc "Creates a solver where each part performs its own parsing."
  def simple_solver(year, day, silver, gold) do
    fn [parts, path] ->
      input = File.read!("#{path}/#{year}/day#{day}.txt") |> String.trim()

      :timer.tc(fn ->
        input
        |> get_parts(parts, silver, gold)
        |> Enum.join("\n")
      end)
    end
  end

  @doc "Creates a solver where both parts receive identical input from a common parsing function."
  def chain_solver(year, day, parse, silver, gold) do
    fn [parts, path] ->
      raw = File.read!("#{path}/#{year}/day#{day}.txt") |> String.trim()

      :timer.tc(fn ->
        parse.(raw)
        |> get_parts(parts, silver, gold)
        |> Enum.join("\n")
      end)
    end
  end

  @doc "Creates a solver where both parts are solved by the same function."
  def double_solver(year, day, parse, solve) do
    fn [parts, path] ->
      raw = File.read!("#{path}/#{year}/day#{day}.txt") |> String.trim()

      :timer.tc(fn ->
        parse.(raw)
        |> solve.()
        |> get_parts(parts, &elem(&1, 0), &elem(&1, 1))
        |> Enum.join("\n")
      end)
    end
  end

end
