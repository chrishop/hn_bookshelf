defmodule HnBookshelf.Bookshelf.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post" do
    field :hn_id, :integer
    field :post_url, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:hn_id, :title, :post_url])
    |> validate_required([:hn_id, :title, :post_url])
  end
end
