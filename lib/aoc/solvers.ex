defmodule AOC.Solvers.Util do
  def input_reader(year, day) do
    day = String.pad_leading("#{day}", 2, "0")
    quote do
      fn root -> File.read!("#{root}/#{unquote(year)}-day#{unquote(day)}.txt") |> String.trim() end
    end
  end

  def parse_parts(s) when s in ["s", "silver"], do: :silver
  def parse_parts(s) when s in ["g", "gold"], do: :gold
  def parse_parts(s) when s in ["b", "both"], do: :both

  def apply_parts(input, parts, silver, gold, opts \\ []) do
    parallel = opts[:parallel]
    case parts do
      :silver -> [silver.(input)]
      :gold -> [gold.(input)]
      :both when not parallel -> [silver.(input), gold.(input)]

      :both ->
        Task.async_stream([silver, gold], fn func -> func.(input) end)
        |> Enum.map(fn {:ok, r} -> r end)
    end
  end
end

defmodule AOC.Solvers.Simple do
  @moduledoc """
  Creates a solver where each part performs its own parsing.

  Both solution functions receive the raw input file text. This is intended for problems where
  parts 1 and 2 require different parsing, and/or are significantly different problems.
  """

  import AOC.Solvers.Util

  defmacro __using__([year, day, silver_fn, gold_fn | opts]) do
    quote do
      def solve_day(input_root, parts) do
        parts = parse_parts(parts)
        reader = unquote(input_reader(year, day))
        raw = reader.(input_root)

        :timer.tc(fn ->
          raw
          |> apply_parts(parts, unquote(silver_fn), unquote(gold_fn), unquote(opts))
          |> Enum.join("\n")
        end)
      end
    end
  end
end

defmodule AOC.Solvers.Chain do
  @moduledoc """
  Creates a solver where both parts receive identical input from a common parsing function.

  `parse_fn` is run once, and its output is passed to each of the solution functions. This reduces
  the total runtime if both parts are being solved in one run.
  """

  import AOC.Solvers.Util

  defmacro __using__([year, day, parse_fn, silver_fn, gold_fn | opts]) do
    quote do
      def solve_day(input_root, parts) do
        parts = parse_parts(parts)
        reader = unquote(input_reader(year, day))
        raw = reader.(input_root)

        :timer.tc(fn ->
          raw
          |> then(unquote(parse_fn))
          |> apply_parts(parts, unquote(silver_fn), unquote(gold_fn), unquote(opts))
          |> Enum.join("\n")
        end)
      end
    end
  end
end

defmodule AOC.Solvers.Double do
  @moduledoc """
  Creates a solver where both parts are solved by the same function.

  `solve_fn` should return a two-element tuple containing the solutions for part 1 and 2.
  """

  import AOC.Solvers.Util

  defmacro __using__([year, day, parse_fn, solve_fn]) do
    quote do
      def solve_day(input_root, parts) do
        parts = parse_parts(parts)
        reader = unquote(input_reader(year, day))
        raw = reader.(input_root)

        :timer.tc(fn ->
          unquote(parse_fn).(raw)
          |> then(unquote(solve_fn))
          |> apply_parts(parts, &elem(&1, 0), &elem(&1, 1))
          |> Enum.join("\n")
        end)
      end
    end
  end
end

defmodule AOC.Solvers.AndThen do
  @moduledoc """
  Creates a solver where the second part relies on data from the first.

  `silver_vn` should return a tuple, where the first element is the solution for part 1, and the
  second element is an arbitrary atom, which (in addition to the parsed input) is passed to
  `gold_fn`.
  """

  import AOC.Solvers.Util

  defmacro __using__([year, day, parse_fn, silver_fn, gold_fn]) do
    quote do
      def solve_day(input_root, parts) do
        parts = parse_parts(parts)
        reader = unquote(input_reader(year, day))
        raw = reader.(input_root)

        :timer.tc(fn ->
          parsed = unquote(parse_fn).(raw)
          {a, acc} = unquote(silver_fn).(parsed)
          case parts do
            :silver -> a
            :gold -> unquote(gold_fn).(parsed, acc)
            :both -> "#{a}\n#{unquote(gold_fn).(parsed, acc)}"
          end
        end)
      end
    end
  end
end
