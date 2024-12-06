defmodule AOC.Main do

  defp solutions, do: %{
    2024 => AOC.Y2024.Index.solutions()
  }

  def main, do: main(System.argv())
  def main(args) do
    [year, day | rest] = args

    solutions()
    |> Map.get(String.to_integer(year))
    |> Enum.at(String.to_integer(day) - 1)
    |> then(fn {mod, _} -> apply(mod, :solver, []).(rest) end)
    |> then(fn {time, res} -> IO.puts("#{res}\n\nRan in #{time / 1000}ms") end)
  end
end
