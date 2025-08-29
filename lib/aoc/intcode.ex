defmodule AOC.Intcode do

  def start() do
    dint_path = System.get_env("DINTCODE_PATH") || Path.join(File.cwd!(), "dintcode/dintcode")
    Port.open({:spawn_executable, dint_path}, [:binary, args: ["--bin"], line: 8])
  end

  def send(port, val) do
    Port.command(port, <<val::unsigned-little-64>>)
  end

  defp to_bitstring(vals) do
    for s <- vals,
        n = <<s::signed-little-64>>,
        reduce: [] do acc ->
          [n | acc]
        end
    |> Enum.reverse()
    |> Enum.join()
  end

  def send_all(port, vals) do
    Port.command(port, to_bitstring(vals))
  end

  def send_program(port, prog) do
    prog = to_bitstring(prog)
    length = <<(byte_size(prog) |> div(8))::unsigned-little-64>>
    Port.command(port, length <> prog)
  end

  def await(port, opts \\ []) do
    pred = opts[:discard] || (fn _ -> true end)
    receive do
      {^port, {:data, {_, <<n::unsigned-little-64>>}}} ->
        if not pred.(n), do: n, else: await(port, opts)
    end
  end

end
