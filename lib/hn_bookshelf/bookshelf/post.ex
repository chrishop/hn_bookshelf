defmodule HnBookshelf.Bookshelf.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post" do
    field :author, :string
    field :comment_number, :integer
    field :date_added, :utc_datetime
    field :date_modified, :utc_datetime
    field :hn_id, :integer
    field :points, :integer
    field :post_url, :string
    field :title, :string
    field :virtual_path, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:hn_id, :title, :post_url, :author, :comment_number, :points, :virtual_path, :date_added, :date_modified])
    |> validate_required([:hn_id, :title, :post_url, :author, :comment_number, :points, :virtual_path, :date_added, :date_modified])
  end
end
