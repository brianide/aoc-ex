defmodule AOC.Scaffold do

  def get_part(str) when str in ["s", "silver"], do: [:silver]
  def get_part(str) when str in ["g", "gold"], do: [:gold]
  def get_part(str) when str in ["b", "both"], do: [:silver, :gold]

  defmodule Solution do
    defmacro __using__(opts) do
      quote do
        def _solution_info, do: unquote(opts)
      end
    end
  end

  defmodule SimpleSolver do
    @moduledoc """
    Creates a solver where each part performs its own parsing.
    """
    defmacro __using__(opts) do
      silver_fn = Keyword.get(opts, :silver, :silver)
      gold_fn = Keyword.get(opts, :gold, :gold)

      quote do
        def _solve(path, part, args \\ []) do
          input = File.read!(path)

          AOC.Scaffold.get_part(part)
          |> Enum.map(fn
            :silver -> apply(__MODULE__, unquote(silver_fn), [input])
            :gold -> apply(__MODULE__, unquote(gold_fn), [input])
          end)
          |> Enum.join("\n")
        end
      end
    end
  end

  defmodule ChainSolver do
    @moduledoc """
    Creates a solver where both parts receive identical input from a common parsing function.
    """
    defmacro __using__(opts) do
      parse_fn = Keyword.get(opts, :parse, :parse)
      silver_fn = Keyword.get(opts, :silver, :silver)
      gold_fn = Keyword.get(opts, :gold, :gold)

      quote do
        def _solve(path, part, args \\ []) do
          input = apply(__MODULE__, unquote(parse_fn), [File.read!(path)])

          AOC.Scaffold.get_part(part)
          |> Enum.map(fn
            :silver -> apply(__MODULE__, unquote(silver_fn), [input])
            :gold -> apply(__MODULE__, unquote(gold_fn), [input])
          end)
          |> Enum.join("\n")
        end
      end
    end
  end

  defmodule DoubleSolver do
    @moduledoc """
    Creates a solver where both parts are solved by the same function.
    """
    defmacro __using__(opts) do
      parse_fn = Keyword.get(opts, :parse, :parse)
      solve_fn = Keyword.get(opts, :solve, :solve)

      quote do
        def _solve(path, part, args \\ []) do
          input = apply(__MODULE__, unquote(parse_fn), [File.read!(path)])
          {ss, gs} = apply(__MODULE__, unquote(solve_fn), [input])

          AOC.Scaffold.get_part(part)
          |> Enum.map(fn
            :silver -> ss
            :gold -> gs
          end)
          |> Enum.join("\n")
        end
      end
    end
  end

end
