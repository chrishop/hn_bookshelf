defmodule HnBookshelf.Repo.Migrations.IntroduceUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:post, [:post_url])
  end
end
