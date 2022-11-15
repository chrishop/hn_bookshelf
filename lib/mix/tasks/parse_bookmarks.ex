defmodule Mix.Tasks.ParseBookmarks do
  use Mix.Task

  alias HnBookshelf.HnApi
  alias HnBookshelf.Bookmark

  def sample_bookmarks() do
    ~s"""
    <!DOCTYPE NETSCAPE-Bookmark-file-1>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
    <Title>Bookmarks</Title>
    <H1>Bookmarks</H1>
    <DL><p>
      <DT><H3 ADD_DATE="1618844074" LAST_MODIFIED="1618844074" PERSONAL_TOOLBAR_FOLDER="true">DuckDuckGo Bookmarks</H3>
      <DL><p>
        <DT><A HREF="https://coronavirus.data.gov.uk/" ADD_DATE="1618844074" LAST_MODIFIED="1618844074">Daily summary | Coronavirus in the UK</A>
        <DT><A HREF="https://news.ycombinator.com/item?id=33503306" ADD_DATE="1618844074" LAST_MODIFIED="1618844074">An Animated Introduction to Elixir | Hacker News</A>
      </DL><p>
      <DT><H3 ADD_DATE="1618844074" LAST_MODIFIED="1618844074">DuckDuckGo Favorites</H3>
      <DL><p>
        <DT><A HREF="https://news.ycombinator.com/item?id=28692470" ADD_DATE="1618844074" LAST_MODIFIED="1618844074">Making Bracket Pair Colorization Faster | Hacker News</A>
      </DL><p>
    </DL><p>
    """
  end

  @impl true
  def run(_) do
    # File.read!(File.cwd!() <> "/priv/static/assets/bookmarks_ddg_20221110.html")
    sample_bookmarks()
    |> Floki.parse_document!()
    |> HnBookshelf.Bookmark.parse_bookmarks()
    |> Enum.map(&enrich/1)
    |> Enum.filter(&hn_item/1)
    |> List.first()
    |> IO.inspect()
  end

  defp enrich(bookmark = %Bookmark{}) do
    with true <- hn_item(bookmark),
         {:ok, id} <- get_item_id(bookmark),
         {:ok, item} <- HnApi.get_item(id),
         {:ok, created_at, _offset} <- DateTime.from_iso8601(item[:created_at]) do
      bookmark
      |> Map.from_struct()
      |> Map.put(:author, item[:author])
      |> Map.put(:title, item[:title])
      |> Map.put(:hn_id, item[:id])
      |> Map.put(:points, item[:points])
      |> Map.put(:type, item[:type])
      |> Map.put(:created_at, created_at)
    else
      _ -> Map.from_struct(bookmark)
    end
  end

  defp hn_item(bookmark) do
    link = bookmark.link

    bookmark.link.host == "news.ycombinator.com" and
      link.path == "/item" and
      String.match?(link.query, ~r/^id=[0-9]+$/)
  end

  defp get_item_id(%Bookmark{link: %URI{query: q}}) do
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
