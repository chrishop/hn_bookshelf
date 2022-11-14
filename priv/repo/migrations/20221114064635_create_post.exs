defmodule HnBookshelf.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:post) do
      add :hn_id, :integer
      add :title, :string
      add :post_url, :string
      add :author, :string
      add :comment_number, :integer
      add :points, :integer
      add :virtual_path, :string
      add :date_added, :utc_datetime
      add :date_modified, :utc_datetime

      timestamps()
    end
  end
end
