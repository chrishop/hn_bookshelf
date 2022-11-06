defmodule HnBookshelf.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:post) do
      add :hn_id, :integer
      add :title, :string
      add :post_url, :string

      timestamps()
    end
  end
end
