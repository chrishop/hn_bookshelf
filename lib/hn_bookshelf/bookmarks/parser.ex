defmodule HnBookshelf.Bookmarks.Parser do
  alias HnBookshelf.Bookmark

  @doc """
  Takes data
  """
  @spec parse(any(), Keyword.t()) :: list(Bookmark.t())
  def parse(document, _opts) do
    document
    |> select_bookmarks()
    |> parse_bookmarks()
  end

  defp select_bookmarks(document) do
    document
    |> Floki.find("a")
  end

  defp parse_bookmarks(bookmarks) when is_list(bookmarks) do
    do_parse_bookmarks(bookmarks, [])
    |> Enum.reverse()
  end

  defp do_parse_bookmarks([], acc), do: acc

  defp do_parse_bookmarks([bookmark | rest], acc) do
    case parse_bookmark(bookmark) do
      {:ok, b} ->
        do_parse_bookmarks(rest, [b | acc])

      {:error, reason} ->
        IO.inspect("""
        cannot parse bookmark with reason: #{reason}, bookmark:
        #{inspect(bookmark)}
        """)

        do_parse_bookmarks(rest, acc)
    end
  end

  defp parse_bookmark({"a", properties, title}) do
    with {:ok, properties} <- parse_properties(properties),
         {:ok, title} <- parse_title(title) do
      {:ok, Map.put(properties, :title, title) |> Bookmark.new()}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_bookmark(_) do
    {:ok, "bookmark incorrect format"}
  end

  defp parse_properties(props) do
    props = to_keyword_list(props)

    with {:ok, link} <- parse_link(props[:href]),
         {:ok, date_added} <- parse_date(props[:add_date]),
         {:ok, last_modified} <- parse_date(props[:last_modified]) do
      {:ok, %{link: link, date_added: date_added, last_modified: last_modified}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_title([title]) when is_binary(title) do
    {:ok, title}
  end

  defp parse_title(_) do
    {:error, "title incorrect format"}
  end

  defp parse_link(link) when is_binary(link), do: {:ok, URI.parse(link)}
  defp parse_link(_), do: {:error, "bad value for link"}

  defp parse_date(timestamp) when is_binary(timestamp) do
    case Integer.parse(timestamp) do
      {t, _remainder} when is_integer(t) -> DateTime.from_unix(t)
      :error -> {:error, "cannot parse timestamp as integer"}
    end
  end

  defp parse_date(_), do: {:error, "timestamp must be an integer string"}

  defp to_keyword_list(properties) do
    Enum.map(
      properties,
      fn {k, v} when is_binary(k) ->
        {String.to_atom(k), v}
      end
    )
  end
end
