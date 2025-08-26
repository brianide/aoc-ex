defmodule Mix.Tasks.Aoc.Solve do
  use Mix.Task

  def run(args) do
    {opts, _} =
      OptionParser.parse!(
        args,
        strict: [year: :integer, day: :integer, root: :string, part: :string, bench: :integer],
        aliases: [y: :year, d: :day, r: :root, p: :part, b: :bench]
      )

    String.to_existing_atom("Elixir.AOC.Y#{opts[:year]}.Day#{opts[:day]}")
    |> Code.ensure_loaded!()
    |> case do mod ->
      case opts[:bench] do
        nil ->
          {_, res} = apply(mod, :solve_day, [opts[:root], opts[:part]])
          IO.puts(res)

        count ->
          for _ <- 1..count, reduce: {0, nil} do {time, _res} ->
            {t, r} = apply(mod, :solve_day, [opts[:root], opts[:part]])
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
