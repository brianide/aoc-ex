defmodule AOC.Site do

  @baseurl "https://adventofcode.com"

  def cookie(dir \\ ".") do
    File.read!(Path.join([dir, ".cookie.dat"]))
    |> String.trim()
    |> case do c -> "session=" <> c end
  end

  def check_started, do: Application.ensure_all_started(:req)

  def get_page(cookie, url) do
    check_started()

    with {:ok, _} <- Application.ensure_all_started(:req),
         {:ok, %{body: body}} <- Req.get(url: url, headers: [cookie: cookie]) do
      {:ok, body}
    else
      err -> err
    end
  end

  @complete_string ~s(<p class="day-success">Both parts of this puzzle are complete!)
  @answer_reg ~r"<p>Your puzzle answer was <code>(.+?)</code>"
  @title_reg ~r"<h2>--- Day \d+: (.+) ---</h2>"

  def get_day_info(cookie, year, day) do
    case get_page(cookie, "#{@baseurl}/#{year}/day/#{day}") do
      {:ok, body} ->
        [title] = Regex.run(@title_reg, body, capture: :all_but_first)

        prog =
          if String.contains?(body, @complete_string) do
            [[a], [b]] = Regex.scan(@answer_reg, body, capture: :all_but_first)
            {:complete, {a, b}}
          else
            :incomplete
          end

        {:ok, %{title: title, progress: prog}}

      err -> err
    end
  end

  def get_day_input(cookie, year, day), do: get_page(cookie, "#{@baseurl}/#{year}/day/#{day}/input")

end
