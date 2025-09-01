Mix.start()
Mix.CLI.main()

defmodule AOCHelpers do
  use Agent

  @persfile ".aociex.dat"

  def set_conf(k, v) do
    Agent.update(__MODULE__, &put_in(&1, [k], v))

    Agent.get(__MODULE__, &(&1))
    |> :erlang.term_to_binary()
    |> then(&File.write!(@persfile, &1))
  end

  def solve(day, part \\ "b") do
    Agent.get(__MODULE__, &(&1))
    |> put_in([:day], day)
    |> put_in([:part], part)
    |> Enum.flat_map(fn {k, v} -> ["--#{Atom.to_string(k)}", "#{v}"] end)
    |> Mix.Tasks.Aoc.Solve.run()
  end

  Agent.start_link(fn ->
    if File.exists?(@persfile) do
      File.read!(@persfile) |> :erlang.binary_to_term()
    else
      %{root: "input/real", bench: 1}
    end
  end, name: __MODULE__)
end

import AOCHelpers
