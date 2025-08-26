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
        AOC.Solution.run_solution(unquote(opts[:scheme]), opts.parts, path)
      end
    end
  end

  def solutions do
    {:ok, mods} = Application.get_application(__MODULE__) |> :application.get_key(:modules)
    for mod <- mods,
        {:module, mod} = Code.ensure_loaded(mod),
        function_exported?(mod, :__aoc_meta__, 0),
        function_exported?(mod, :__aoc_run__, 1),
        reduce: %{} do acc ->
          {year, day} = apply(mod, :__aoc_meta__, []).date
          put_in(acc, [Access.key(year, %{}), day], mod)
        end
  end

  def run_solution({:separate, silv_fn, gold_fn}, parts, path) do
    raw = File.read!(path)

    :timer.tc(fn ->
      case parts do
        :silver -> silv_fn.(raw)
        :gold -> gold_fn.(raw)
        :both -> "#{silv_fn.(raw)}\n#{gold_fn.(raw)}"
      end
    end)
  end

  def run_solution({:shared, parse_fn, silv_fn, gold_fn}, parts, path) do
    raw = File.read!(path)

    :timer.tc(fn ->
      parsed = parse_fn.(raw)
      case parts do
        :silver -> silv_fn.(parsed)
        :gold -> gold_fn.(parsed)
        :both -> "#{silv_fn.(parsed)}\n#{gold_fn.(parsed)}"
      end
    end)
  end

  def run_solution({:single, parse_fn, solve_fn}, parts, path) do
    raw = File.read!(path)

    :timer.tc(fn ->
      {s, g} = raw |> parse_fn.() |> solve_fn.()
      case parts do
        :silver -> s
        :gold -> g
        :both -> "#{s}\n#{g}"
      end
    end)
  end

  def run_solution({:chain, parse_fn, silv_fn, gold_fn}, parts, path) do
    raw = File.read!(path)

    :timer.tc(fn ->
      parsed = parse_fn.(raw)
      {a, acc} = silv_fn.(parsed)
      case parts do
        :silver -> a
        :gold -> gold_fn.(parsed, acc)
        :both -> "#{a}\n#{gold_fn.(parsed, acc)}"
      end
    end)
  end

end
