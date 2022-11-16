defmodule HnBookshelf.Repo.Migrations.DepopulatePosts do
  use Ecto.Migration

  def change do
    HnBookshelf.Bookshelf.list_post()
    |> Enum.map(fn p ->
      HnBookshelf.Bookshelf.delete_post(p)
    end)
  end
end
