defmodule HnBookshelf.Bookmark do
  alias HnBookshelf.HnApi

  @type t :: %__MODULE__{
          title: String.t(),
          link: URI.t(),
          date_added: DateTime.t(),
          last_modified: DateTime.t()
        }

  @enforce_keys [:title, :link, :date_added, :last_modified]
  defstruct [:title, :link, :date_added, :last_modified]

  def new(title, link, date_added, last_modified) do
    %__MODULE__{
      title: title,
      link: link,
      date_added: date_added,
      last_modified: last_modified
    }
  end

  def new(bookmark) when is_map(bookmark) do
    %__MODULE__{
      title: String.slice(bookmark[:title], 0..254),
      link: bookmark[:link],
      date_added: bookmark[:date_added],
      last_modified: bookmark[:last_modified]
    }
  end

  @spec parse_bookmarks(any(), Keyword.t()) :: list(t())
  def parse_bookmarks(document, _opts \\ []) do
    document
    |> select_bookmarks()
    |> do_parse_bookmarks([])
    |> Enum.reverse()
  end

  @spec enrich_bookmarks(list(t)) :: list(map())
  def enrich_bookmarks(bookmarks) when is_list(bookmarks) do
    Enum.map(bookmarks, &enrich/1)
  end

  @spec enrich(t) :: map()
  def enrich(bookmark = %__MODULE__{}) do
    with true <- hn_item(bookmark),
         {:ok, id} <- get_item_id(bookmark),
         {:ok, item} <- HnApi.get_item(id) do
      title = item[:title] || bookmark.title
      created_at = DateTime.from_unix!(item[:created_at_i])

      bookmark
      |> Map.from_struct()
      |> Map.put(:author, item[:author])
      |> Map.put(:title, title)
      |> Map.put(:hn_id, item[:id])
      |> Map.put(:points, item[:points])
      |> Map.put(:type, item[:type])
      |> Map.put(:created_at, created_at)
    else
      _ -> Map.from_struct(bookmark)
    end
  end

  def to_post_attrs(bookmark = %__MODULE__{}) do
    %{
      title: bookmark.title,
      post_url: URI.to_string(bookmark.link),
      date_added: bookmark.date_added,
      date_modified: bookmark.last_modified
    }
  end

  def to_post_attrs(enriched_bookmark) when is_map(enriched_bookmark) do
    %{
      title: enriched_bookmark[:title],
      post_url: URI.to_string(enriched_bookmark[:link]),
      hn_id: enriched_bookmark[:hn_id],
      author: enriched_bookmark[:author],
      # TODO need to implement this, will return nil
      comment_number: enriched_bookmark[:comment_number],
      points: enriched_bookmark[:points],
      # virtual_path is decided on later
      virtual_path: nil,
      date_added: enriched_bookmark[:date_added],
      date_modified: enriched_bookmark[:last_modified]
    }
  end

  defp select_bookmarks(document) do
    document
    |> Floki.find("a")
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
      {:ok, Map.put(properties, :title, title) |> new()}
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
      _ -> {:error, "cannot parse timestamp as integer"}
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

  defp hn_item(bookmark) do
    link = bookmark.link

    bookmark.link.host == "news.ycombinator.com" &&
      link.path == "/item" &&
      String.match?(link.query || "", ~r/^id=[0-9]+$/)
  end

  defp get_item_id(%__MODULE__{link: %URI{query: q}}) do
    decoded_query =
      URI.query_decoder(q)
      |> Enum.to_list()

    with [{"id", str_id}] <- decoded_query, {id, _rem} <- Integer.parse(str_id) do
      {:ok, id}
    else
      _ -> {:error, "cannot get item id from bookmark"}
    end
  end
end
