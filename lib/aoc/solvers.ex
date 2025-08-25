defmodule AOC.Solvers.Util do
  def input_reader(year, day) do
    day = String.pad_leading("#{day}", 2, "0")
    quote do
      fn root -> File.read!("#{root}/#{unquote(year)}-day#{unquote(day)}.txt") |> String.trim() end
    end
  end

  def get_parts(input, parts, silver, gold, opts \\ []) do
    parallel = opts[:parallel]
    case parts do
      s when s in ["s", "silver"] ->
        [silver.(input)]
      s when s in ["g", "gold"] ->
        [gold.(input)]
      s when s in ["b", "both"] when parallel ->
        Task.async_stream([silver, gold], fn func ->
          func.(input)
        end)
        |> Enum.map(fn {:ok, r} -> r end)
      s when s in ["b", "both"] ->
        [silver.(input), gold.(input)]
    end
  end
end

defmodule AOC.Solvers.Simple do
  @moduledoc "Creates a solver where each part performs its own parsing."

  import AOC.Solvers.Util

  defmacro __using__([year, day, silver_fn, gold_fn | opts]) do
    quote do
      def solve_day(input_root, parts) do
        reader = unquote(input_reader(year, day))
        raw = reader.(input_root)

        :timer.tc(fn ->
          raw
          |> get_parts(parts, unquote(silver_fn), unquote(gold_fn), unquote(opts))
          |> Enum.join("\n")
        end)
      end
    end
  end
end

defmodule AOC.Solvers.Chain do
  @moduledoc "Creates a solver where both parts receive identical input from a common parsing function."

  import AOC.Solvers.Util

  defmacro __using__([year, day, parse_fn, silver_fn, gold_fn | opts]) do
    quote do
      def solve_day(input_root, parts) do
        reader = unquote(input_reader(year, day))
        raw = reader.(input_root)

        :timer.tc(fn ->
          raw
          |> then(unquote(parse_fn))
          |> get_parts(parts, unquote(silver_fn), unquote(gold_fn), unquote(opts))
          |> Enum.join("\n")
        end)
      end
    end
  end
end

defmodule AOC.Solvers.Double do
  @moduledoc "Creates a solver where both parts are solved by the same function."

  import AOC.Solvers.Util

  defmacro __using__([year, day, parse_fn, solve_fn]) do
    quote do
      def solve_day(input_root, parts) do
        reader = unquote(input_reader(year, day))
        raw = reader.(input_root)

        :timer.tc(fn ->
          unquote(parse_fn).(raw)
          |> then(unquote(solve_fn))
          |> get_parts(parts, &elem(&1, 0), &elem(&1, 1))
          |> Enum.join("\n")
        end)
      end
    end
  end
end
