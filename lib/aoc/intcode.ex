defmodule AOC.Intcode do

  def start(progfile) do
    dint_path = System.get_env("DINTCODE_PATH") || Path.join(File.cwd!(), "dintcode/dintcode")
    Port.open({:spawn_executable, dint_path}, [:binary, :exit_status, args: [progfile, "--"], line: 16])
  end

end
