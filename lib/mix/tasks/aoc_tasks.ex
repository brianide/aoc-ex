defmodule Mix.Tasks.Aoc.Solve do
  use Mix.Task

  @shortdoc "Run an Advent of Code solution"
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
            IO.puts("#{res}\n\n#{IO.ANSI.light_green()}#{label} #{time / count / 1000}ms#{IO.ANSI.default_color()}")
          end
      end
    end
  end
end

defmodule Mix.Tasks.Aoc.List do
  use Mix.Task

  def rotate([h | rest]), do: rest ++ [h]

  def year_colors([%{date: {year, _}} | _] = list, colors), do: year_colors(list, colors, year, [])

  def year_colors([], _colors, _prev, done), do: Enum.reverse(done)

  def year_colors([h | rest], [a, b | _] = colors, prev, done) do
    {year, _} = h.date
    cond do
      year == prev ->
        year_colors(rest, colors, prev, [put_in(h[:color], a) | done])

      :else ->
        year_colors(rest, rotate(colors), year, [put_in(h[:color], b) | done])
    end
  end

  @colors [IO.ANSI.blue(), IO.ANSI.light_blue()]

  @shortdoc "List available Advent of Code solution statuses"
  def run([]) do
    Stream.flat_map(AOC.Solution.solutions(), fn {_year, days} -> for {_day, mod} <- days, do: mod end)
    |> Stream.map(&apply(&1, :__aoc_meta__, []))
    |> Enum.sort_by(&Access.get(&1, :date))
    |> year_colors(@colors)
    |> Enum.each(fn meta ->
      {year, day} = meta.date
      check = meta.complete && "[x] " || "[ ] "
      date = "#{year} |" <> String.pad_leading("#{day} | ", 6)
      comp_color = meta.complete && IO.ANSI.green() || IO.ANSI.red()
      line_color = meta.favorite && IO.ANSI.yellow() || meta.color
      IO.puts(comp_color <> check <> line_color <> date <> meta.title <> IO.ANSI.default_color())
    end)
  end
end

defmodule Mix.Tasks.Aoc.Edit do
  use Mix.Task

  @shortdoc "Edit the file for the selected day"
  def run([year, day]) do
    System.cmd("code", ["lib/aoc/y#{year}/day#{day}.ex", "input/real/#{year}-day#{String.pad_leading(day, 2, "0")}.txt"])
  end
end
