defmodule HnBookshelf.Bookshelf do
  @moduledoc """
  The Bookshelf context.
  """

  import Ecto.Query, warn: false
  alias HnBookshelf.Repo

  alias HnBookshelf.Bookshelf.Post

  @doc """
  Returns the list of post.

  ## Examples

      iex> list_post()
      [%Post{}, ...]

  """
  def list_post do
    Repo.all(Post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  def get_post_page(page_no, folder, item_per_page \\ 30)
      when is_integer(page_no) and page_no >= 1 do
    offset = (page_no - 1) * item_per_page

    post_with_folder =
      if folder do
        where(Post, [p], p.virtual_path == ^folder)
      else
        where(Post, [p], is_nil(p.virtual_path))
      end

    post_with_folder
    |> order_by([p], p.date_added)
    |> limit(^item_per_page)
    |> offset(^offset)
    |> Repo.all()
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def update_folder(post = %Post{}, folder) do
    post
    |> Post.folder_changeset(%{virtual_path: folder})
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
