defmodule AOC.Solution do

  defmacro __using__(opts) do
    opts = Keyword.validate!(opts, [:title, :url, :scheme, newline: :trim, complete: false, favorite: false, tags: []])

    [url, year, day] = Regex.run(~r"https://adventofcode\.com/(\d+)/day/(\d+)", opts[:url])
    file = "#{year}-day#{String.pad_leading(day, 2, "0")}.txt"
    date = {String.to_integer(year), String.to_integer(day)}
    trim = opts[:newline] === :trim

    quote do
      def __aoc_meta__, do: %{
        title: unquote(opts[:title]),
        url: unquote(url),
        date: unquote(date),
        complete: unquote(opts[:complete]),
        favorite: unquote(opts[:favorite]),
        tags: unquote(opts[:tags])
      }

      def __aoc_run__(opts) do
        path = Path.join([opts.input_root, unquote(file)])
        apply(unquote(__MODULE__), :run_solution, [unquote(opts[:scheme]), opts.part, path, unquote(trim)])
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

  @doc "Reads a file, dropping any trailing newlines"
  def read_file(path) do
    File.read!(path)
    |> String.split("\n")
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 == ""))
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  def run_solution(scheme, part, path, trim) do
    raw = if trim, do: read_file(path), else: File.read!(path)
    run_solution(scheme, part, raw)
  end

  @doc """
  Creates a solver according to one of several schemes:

  ## :custom
  The least opinionated option.

  Parsing and solving are both handled by the passed function. The function should return a
  two-element tuple containing the solutions for parts 1 and 2.

  ## :separate
  Each part performs its own parsing and processing.

  Both solution functions receive the raw input file text. This is intended for problems where
  parts 1 and 2 require different parsing, and/or are significantly different problems.

  ## :shared
  Both parts receive identical input from a shared parsing function.

  `parse_fn` is run once, and its output is passed to each of the solution functions. This reduces
  the total runtime if both parts are being solved in one run.

  ## :once
  Both parts are solved at once by the same function.

  `solve_fn` should return a two-element tuple containing the solutions for part 1 and 2.

  ## :chain
  The second part relies on data from the first.

  `silver_vn` should return a tuple, where the first element is the solution for part 1, and the
  second element is an arbitrary atom, which (in addition to the parsed input) is passed to
  `gold_fn`.
  """
  def run_solution(scheme, part, path)

  def run_solution({:custom, solve_fn}, part, raw) do
    :timer.tc(fn ->
      {s, g} = raw |> solve_fn.()
      case part do
        :silver -> s
        :gold -> g
        :both -> "#{s}\n#{g}"
      end
    end)
  end

  def run_solution({:separate, silv_fn, gold_fn}, part, raw) do
    :timer.tc(fn ->
      case part do
        :silver -> silv_fn.(raw)
        :gold -> gold_fn.(raw)
        :both -> "#{silv_fn.(raw)}\n#{gold_fn.(raw)}"
      end
    end)
  end

  def run_solution({:shared, parse_fn, silv_fn, gold_fn}, part, raw) do
    :timer.tc(fn ->
      parsed = parse_fn.(raw)
      case part do
        :silver -> silv_fn.(parsed)
        :gold -> gold_fn.(parsed)
        :both -> "#{silv_fn.(parsed)}\n#{gold_fn.(parsed)}"
      end
    end)
  end

  def run_solution({:once, parse_fn, solve_fn}, part, raw) do
    :timer.tc(fn ->
      {s, g} = raw |> parse_fn.() |> solve_fn.()
      case part do
        :silver -> s
        :gold -> g
        :both -> "#{s}\n#{g}"
      end
    end)
  end

  def run_solution({:chain, parse_fn, silv_fn, gold_fn}, part, raw) do
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

  def run_solution({:intcode, silv_fn, gold_fn}, part, raw) do
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
