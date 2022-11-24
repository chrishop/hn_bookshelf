defmodule HnBookshelf.Bookshelf.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          author: String.t(),
          comment_number: integer(),
          date_added: DateTime.t(),
          date_modified: DateTime.t(),
          hn_id: integer(),
          points: integer(),
          post_url: String.t(),
          title: String.t(),
          virtual_path: String.t()
        }

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
    |> cast(attrs, [
      :hn_id,
      :title,
      :post_url,
      :author,
      :comment_number,
      :points,
      :virtual_path,
      :date_added,
      :date_modified
    ])
    |> validate_required([:title, :post_url, :date_added, :date_modified])
    |> unique_constraint(:post_url)
    |> validate_length(:author, max: 255)
    |> validate_length(:post_url, max: 255)
    |> validate_length(:title, max: 255)
    |> validate_length(:virtual_path, max: 255)
  end

  def folder_changeset(post, attrs) do
    post
    |> cast(attrs, [:virtual_path])
    |> validate_required([:virtual_path])
    |> validate_length(:virtual_path, max: 255)
  end
end
