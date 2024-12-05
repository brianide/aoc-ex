defmodule AOC.Scaffold do

  defmodule Solution do
    @type solution_spec() :: {integer(), integer(), String.t()}
    @callback solution_info :: solution_spec()
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
          input = File.read!(path) |> String.trim()

          Enum.map(part, fn
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
          input = apply(__MODULE__, unquote(parse_fn), [File.read!(path) |> String.trim()])

          Enum.map(part, fn
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
      opts = Keyword.merge([parse: :parse, solve: :solve], opts)

      quote do
        def _solve(path, part, args \\ []) do
          input = apply(__MODULE__, unquote(opts[:parse]), [File.read!(path) |> String.trim()])
          {ss, gs} = apply(__MODULE__, unquote(opts[:solve]), [input])

          Enum.map(part, fn
            :silver -> ss
            :gold -> gs
          end)
          |> Enum.join("\n")
        end
      end
    end
  end

end
