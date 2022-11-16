defmodule Mix.Tasks.ParseBookmarks do
  use Mix.Task

  alias HnBookshelf.HnApi
  alias HnBookshelf.Bookmark
  alias HnBookshelf.Bookshelf.Post

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
    Application.ensure_all_started(:hn_bookshelf)

    File.read!(File.cwd!() <> "/priv/static/assets/bookmarks_ddg_20221110.html")
    # sample_bookmarks()
    |> Floki.parse_document!()
    |> Bookmark.parse_bookmarks()
    |> then(fn b ->
      Task.Supervisor.async_stream(HnBookshelf.TaskSupervisor, b, fn x -> enrich(x) end,
        timeout: :infinity
      )
    end)
    |> Stream.map(fn {:ok, m} -> m end)
    |> Stream.take(200)
    |> Enum.to_list()
    |> merge_duplicates()
    |> Enum.map(&Bookmark.to_post_attrs/1)
    |> Enum.map(&add_to_db/1)
  end

  defp enrich(b) do
    IO.inspect(b.title, label: "enriching")

    Bookmark.enrich(b)
  end

  defp merge_duplicates(bl) do
    Bookmark.merge_duplicates(bl)
  end

  defp add_to_db(attrs) do
    Post.changeset(%Post{}, attrs)
    |> then(fn c ->
      if Enum.empty?(c.errors) do
        # HnBookshelf.Repo.insert(c)
        :inserted
      else
        IO.inspect(c, label: "changeset error")
      end
    end)
  end
end
