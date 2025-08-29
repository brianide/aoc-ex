defmodule AOC.Y2019.Day5 do
  use AOC.Solution,
    title: "Sunny with a Chance of Asteroids",
    url: "https://adventofcode.com/2019/day/5",
    scheme: {:intcode, &solve(&1, 1), &solve(&1, 5)},
    complete: false

  def listen(port) do
    receive do
      {^port, {:data, {:eol, "0"}}} ->
        listen(port)

      {^port, {:data, {:eol, n}}} ->
        Port.close(port)
        n
    end
  end

  def solve(file, n) do
    port = AOC.Intcode.start(file)
    Port.command(port, "#{n}\n")
    listen(port)
  end

end
