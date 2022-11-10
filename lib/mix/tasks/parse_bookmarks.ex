defmodule Mix.Tasks.ParseBookmarks do
  @moduledoc "The hello mix task: `mix help hello`"
  use Mix.Task

  ### NEED TO MOVE THIS INTO ITS OWN MODULE WITH TESTS

  @shortdoc "Simply calls the Hello.say/0 function."
  def run(_) do
    File.read!(File.cwd!() <> "/priv/static/assets/bookmarks_ddg_20221110.html")
    |> Floki.parse_document!()
    |> select_ddg_bookmarks()
    |> parse_bookmarks()
    |> IO.inspect()
    |> tap(fn d -> IO.inspect(length(d)) end)
  end

  def select_ddg_bookmarks(document) do
    document
    |> Floki.find("dl")
    |> Floki.find("p")
    |> Floki.find("dl")
    |> Floki.find("dt")
    |> Floki.find("a")
  end

  def parse_bookmarks(bookmarks) when is_list(bookmarks) do
    do_parse_bookmarks(bookmarks, [])
  end

  def do_parse_bookmarks([], acc), do: acc

  def do_parse_bookmarks([bookmark | rest], acc) do
    case parse_bookmark(bookmark) do
      {:ok, bookmark} ->
        do_parse_bookmarks(rest, [bookmark | acc])

      {:error, reason} ->
        IO.inspect("""
        cannot parse bookmark with reason: #{reason}, bookmark:
        #{inspect(bookmark)}
        """)

        do_parse_bookmarks(rest, acc)
    end
  end

  def parse_bookmark({"a", properties, title}) do
    with {:ok, properties} <- parse_properties(properties),
         {:ok, title} <- parse_title(title) do
      {:ok, Map.put(properties, :title, title)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def parse_bookmark(_) do
    {:ok, "bookmark incorrect format"}
  end

  def parse_properties(props) do
    props = to_keyword_list(props)

    with {:ok, link} <- parse_link(props[:href]),
         {:ok, date_added} <- parse_date(props[:add_date]),
         {:ok, date_modified} <- parse_date(props[:last_modified]) do
      {:ok, %{link: link, date_added: date_added, date_modified: date_modified}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def parse_title([title]) when is_binary(title) do
    {:ok, title}
  end

  def parse_title(_) do
    {:error, "title incorrect format"}
  end

  def parse_link(link) when is_binary(link), do: {:ok, URI.parse(link)}
  def parse_link(_), do: {:error, "bad value for link"}

  def parse_date(timestamp) when is_binary(timestamp) do
    case Integer.parse(timestamp) do
      {t, _remainder} when is_integer(t) -> DateTime.from_unix(t)
      :error -> {:error, "cannot parse timestamp as integer"}
    end
  end

  def parse_date(_), do: {:error, "timestamp must be an integer string"}

  defp to_keyword_list(properties) do
    Enum.map(
      properties,
      fn {k, v} when is_binary(k) ->
        {String.to_atom(k), v}
      end
    )
  end
end
