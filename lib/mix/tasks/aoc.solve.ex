defmodule Mix.Tasks.Aoc.Solve do
  use Mix.Task

  def run(args) do
    {opts, _} =
      OptionParser.parse!(
        args,
        strict: [year: :integer, day: :integer, root: :string, part: :string, bench: :boolean],
        aliases: [y: :year, d: :day, r: :root, p: :part, b: :bench]
      )

    String.to_existing_atom("Elixir.AOC.Y#{opts[:year]}.Day#{opts[:day]}")
    |> Code.ensure_loaded!()
    |> case do mod ->
      {time, res} = apply(mod, :solve_day, [opts[:root], opts[:part]])
      IO.puts(res)
      if opts[:bench], do: IO.puts("\nRan in #{time / 1000}ms")
    end
  end
end
