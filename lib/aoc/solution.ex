defmodule AOC.Solution do

  defmacro __using__(opts) do
    opts = Keyword.validate!(opts, [:title, :url, :scheme, complete: false, favorite: false])

    [url, year, day] = Regex.run(~r"https://adventofcode\.com/(\d+)/day/(\d+)", opts[:url])
    file = "#{year}-day#{String.pad_leading(day, 2, "0")}.txt"
    date = {String.to_integer(year), String.to_integer(day)}

    quote do
      def __aoc_meta__, do: %{
        title: unquote(opts[:title]),
        url: unquote(url),
        date: unquote(date),
        complete: unquote(opts[:complete]),
        favorite: unquote(opts[:favorite])
      }

      def __aoc_run__(opts) do
        path = Path.join([opts.input_root, unquote(file)])
        apply(unquote(__MODULE__), :run_solution, [unquote(opts[:scheme]), opts.part, path])
      end
    end
  end

  def solutions do
    {:ok, mods} = Application.get_application(__MODULE__) |> :application.get_key(:modules)
    for mod <- mods,
        {:module, mod} = Code.ensure_loaded(mod),
        function_exported?(mod, :__aoc_meta__, 0),
        reduce: %{} do acc ->
          {year, day} = apply(mod, :__aoc_meta__, []).date
          put_in(acc, [Access.key(year, %{}), day], mod)
        end
  end

  @doc """
  Creates a solver according to one of several schemes:

  ## :separate
  Creates a solver where each part performs its own parsing and processing.

  Both solution functions receive the raw input file text. This is intended for problems where
  parts 1 and 2 require different parsing, and/or are significantly different problems.

  ## :shared
  Creates a solver where both parts receive identical input from a shared parsing function.

  `parse_fn` is run once, and its output is passed to each of the solution functions. This reduces
  the total runtime if both parts are being solved in one run.

  ## :once
  Creates a solver where both parts are solved at once by the same function.

  `solve_fn` should return a two-element tuple containing the solutions for part 1 and 2.

  ## :chain
  Solver where the second part relies on data from the first.

  `silver_vn` should return a tuple, where the first element is the solution for part 1, and the
  second element is an arbitrary atom, which (in addition to the parsed input) is passed to
  `gold_fn`.
  """
  def run_solution(scheme, part, path)

  def run_solution({:separate, silv_fn, gold_fn}, part, path) do
    raw = File.read!(path) |> String.trim()

    :timer.tc(fn ->
      case part do
        :silver -> silv_fn.(raw)
        :gold -> gold_fn.(raw)
        :both -> "#{silv_fn.(raw)}\n#{gold_fn.(raw)}"
      end
    end)
  end

  def run_solution({:shared, parse_fn, silv_fn, gold_fn}, part, path) do
    raw = File.read!(path) |> String.trim()

    :timer.tc(fn ->
      parsed = parse_fn.(raw)
      case part do
        :silver -> silv_fn.(parsed)
        :gold -> gold_fn.(parsed)
        :both -> "#{silv_fn.(parsed)}\n#{gold_fn.(parsed)}"
      end
    end)
  end

  def run_solution({:once, parse_fn, solve_fn}, part, path) do
    raw = File.read!(path) |> String.trim()

    :timer.tc(fn ->
      {s, g} = raw |> parse_fn.() |> solve_fn.()
      case part do
        :silver -> s
        :gold -> g
        :both -> "#{s}\n#{g}"
      end
    end)
  end

  def run_solution({:chain, parse_fn, silv_fn, gold_fn}, part, path) do
    raw = File.read!(path) |> String.trim()

    :timer.tc(fn ->
      parsed = parse_fn.(raw)
      {a, acc} = silv_fn.(parsed)
      case part do
        :silver -> a
        :gold -> gold_fn.(parsed, acc)
        :both -> "#{a}\n#{gold_fn.(parsed, acc)}"
      end
    end)
  end

  def run_solution({:intcode, silv_fn, gold_fn}, part, path) do
    raw = File.read!(path) |> String.trim()

    :timer.tc(fn ->
      prog = (for s <- String.splitter(raw, ","), do: String.to_integer(s))

      case part do
        :silver -> silv_fn.(prog)
        :gold -> gold_fn.(prog)
        :both -> "#{silv_fn.(prog)}\n#{gold_fn.(prog)}"
      end
    end)
  end

end
