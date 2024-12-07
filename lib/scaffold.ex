defmodule AOC.Scaffold do

  defp get_part(str) when str in ["s", "silver"], do: [:silver]
  defp get_part(str) when str in ["g", "gold"], do: [:gold]
  defp get_part(str) when str in ["b", "both"], do: [:silver, :gold]

  @doc "Creates a solver where each part performs its own parsing."
  def simple_solver(year, day, silver, gold) do
    fn [parts, path] ->
      input = File.read!("#{path}/#{year}/day#{day}.txt") |> String.trim()

      :timer.tc(fn ->
        get_part(parts)
        |> Stream.map(fn
          :silver -> silver.(input)
          :gold -> gold.(input)
        end)
        |> Enum.join("\n")
      end)
    end
  end

  @doc "Creates a solver where both parts receive identical input from a common parsing function."
  def chain_solver(year, day, parse, silver, gold) do
    fn [parts, path] ->
      raw = File.read!("#{path}/#{year}/day#{day}.txt") |> String.trim()

      :timer.tc(fn ->
        input = parse.(raw)

        get_part(parts)
        |> Stream.map(fn
          :silver -> silver.(input)
          :gold -> gold.(input)
        end)
        |> Enum.join("\n")
      end)

    end
  end

  @doc "Creates a solver where both parts are solved by the same function."
  def double_solver(year, day, parse, solve) do
    fn [parts, path] ->
      raw = File.read!("#{path}/#{year}/day#{day}.txt") |> String.trim()

      :timer.tc(fn ->
        input = parse.(raw) |> solve.()

        get_part(parts)
        |> Stream.map(fn
          :silver -> elem(input, 0)
          :gold -> elem(input, 1)
        end)
        |> Enum.join("\n")
      end)
    end
  end

end
