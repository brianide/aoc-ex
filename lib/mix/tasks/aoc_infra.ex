defmodule Mix.Tasks.Aoc.Scaff do
  use Mix.Task

  def template(ops), do: """
    defmodule AOC.Y#{ops.year}.Day#{ops.day} do
      use AOC.Solution,
        title: "#{ops.title}",
        url: "https://adventofcode.com/#{ops.year}/day/#{ops.day}",
        scheme: {:shared, &parse/1, &silver/1, &gold/1},
        complete: false

      def parse(input) do
        input
      end

      def silver(input) do
        input
        |> inspect(charlists: :as_lists)
      end

      def gold(_input) do
        "Not implemented"
      end

    end
    """

  def template_intcode(ops), do: """
    defmodule AOC.Y#{ops.year}.Day#{ops.day} do
      use AOC.Solution,
        title: "#{ops.title}",
        url: "https://adventofcode.com/#{ops.year}/day/#{ops.day}",
        scheme: {:intcode, &silver/1, &gold/1},
        complete: false

      def silver(_file) do
        "Not implemented"
      end

      def gold(_file) do
        "Not implemented"
      end

    end
    """

  @shortdoc "Scaffold an AoC solution"
  def run(args) do
    {opts, [year, day]} = OptionParser.parse!(args, switches: [intcode: :boolean, edit: :boolean], aliases: [ic: :intcode])

    cookie = AOC.Site.cookie()
    path = "lib/aoc/y#{year}"
    exfile = "#{path}/day#{day}.ex"
    infile = "input/real/#{year}-day#{String.pad_leading(day, 2, "0")}.txt"
    with :ok <- AOC.Util.ensure_dir(path),
         :ok <- AOC.Util.ensure_dir("input/real"),
         {:ok, info} <- AOC.Site.get_day_info(cookie, year, day),
         {:ok, input} <- AOC.Site.get_day_input(cookie, year, day) do

      if not File.exists?(exfile) do
        params = %{year: year, day: day, title: info.title}
        text = if opts[:intcode], do: template_intcode(params), else: template(params)
        File.write!(exfile, text)
        Mix.Shell.IO.info("Wrote solution file: #{exfile}")
      else
        Mix.Shell.IO.info("File already exists: #{exfile}")
      end

      if not File.exists?(infile) do
        File.write!(infile, input)
        Mix.Shell.IO.info("Wrote input file: #{infile}")
      else
        Mix.Shell.IO.info("File already exists: #{infile}")
      end

      if (opts[:edit]), do: Mix.Tasks.Aoc.Edit.run([year, day])

    end
  end
end

defmodule Mix.Tasks.Aoc.Results do
  use Mix.Task

  @shortdoc "Fetch expected values for a completed day"
  def run([year, day]) do
    cookie = AOC.Site.cookie()
    file = "expected/#{year}-day#{String.pad_leading(day, 2, "0")}.txt"
    with :ok <- AOC.Util.ensure_dir("expected"),
         {:ok, info} <- AOC.Site.get_day_info(cookie, year, day) do

      if not File.exists?(file) do
        case info do
          %{progress: {:complete, {a, b}}} ->
            text = "#{a}\n#{b}"
            File.write!(file, text)
            Mix.Shell.IO.info("Wrote expected values file: #{file}")
          _ ->
            Mix.Shell.IO.info("Problem hasn't been solved yet!")
        end
      else
        Mix.Shell.IO.info("File already exists: #{file}")
      end

    end
  end
end
