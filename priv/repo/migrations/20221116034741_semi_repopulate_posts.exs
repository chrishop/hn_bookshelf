defmodule HnBookshelf.Repo.Migrations.SemiRepopulatePosts do
  use Ecto.Migration

  alias HnBookshelf.Bookmark
  alias HnBookshelf.Bookshelf.Post

  def change do
    File.read!(File.cwd!() <> "/priv/static/assets/bookmarks_ddg_20221110.html")
    # sample_bookmarks()
    |> Floki.parse_document!()
    |> Bookmark.parse_bookmarks()
    |> Task.async_stream(fn x -> enrich(x) end, timeout: :infinity)
    |> Stream.map(fn {:ok, m} -> m end)
    |> Enum.to_list()
    |> Bookmark.merge_duplicates()
    |> Enum.map(&Bookmark.to_post_attrs/1)
    |> Enum.map(&add_to_db/1)
  end

  defp enrich(b) do
    IO.inspect(b.title, label: "enriching")

    Bookmark.enrich(b)
  end

  defp add_to_db(attrs) do
    Post.changeset(%Post{}, attrs)
    |> then(fn c ->
      if Enum.empty?(c.errors) do
        HnBookshelf.Repo.insert(c)
      else
        IO.inspect(c, label: "changeset error")
      end
    end)
  end
end
