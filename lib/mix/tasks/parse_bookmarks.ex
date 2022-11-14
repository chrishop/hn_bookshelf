defmodule Mix.Tasks.ParseBookmarks do
  use Mix.Task

  @impl true
  def run(_) do
    File.read!(File.cwd!() <> "/priv/static/assets/bookmarks_ddg_20221110.html")
    |> Floki.parse_document!()
    |> HnBookshelf.Bookmarks.Parser.parse([])
  end
end
