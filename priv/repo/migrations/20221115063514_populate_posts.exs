defmodule HnBookshelf.Repo.Migrations.PopulatePosts do
  use Ecto.Migration

  alias HnBookshelf.Bookmark
  alias HnBookshelf.Bookshelf.Post

  def change do
    # Had to comment this out, for some reason this was running everytime I ran `mix test`

    # Application.ensure_all_started(:hn_bookshelf)

    # File.read!(File.cwd!() <> "/priv/static/assets/bookmarks_ddg_20221110.html")
    # # sample_bookmarks()
    # |> Floki.parse_document!()
    # |> Bookmark.parse_bookmarks()
    # |> Enum.map(fn x -> enrich(x) |> add_to_db() end)
  end

  defp enrich(b) do
    IO.inspect(b.title, label: "enriching (hello)")

    Bookmark.enrich(b)
    |> Bookmark.to_post_attrs()
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
