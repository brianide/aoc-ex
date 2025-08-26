defmodule Mix.Tasks.Aoc.Solve do
  use Mix.Task

  def run(args) do
    {opts, _} =
      OptionParser.parse!(
        args,
        strict: [year: :integer, day: :integer, root: :string, part: :string, bench: :integer],
        aliases: [y: :year, d: :day, r: :root, p: :part, b: :bench]
      )

    AOC.Solution.solutions()
    |> get_in([opts[:year], opts[:day]])
    |> case do mod ->
      run_opts = [%{
        input_root: opts[:root],
        part: AOC.Util.parse_parts(opts[:part])
      }]

      case opts[:bench] do
        nil ->
          {_, res} = apply(mod, :__aoc_run__, run_opts)
          IO.puts(res)

        count ->
          for _ <- 1..count, reduce: {0, nil} do {time, _res} ->
            {t, r} = apply(mod, :__aoc_run__, run_opts)
            {time + t, r}
          end
          |> case do {time, res} ->
            label = if count > 1, do: "Average runtime:", else: "Ran in"
            IO.puts("#{res}\n\n#{label} #{time / count / 1000}ms")
          end
      end
    end
  end
end
