defmodule HnBookshelf.BookshelfFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HnBookshelf.Bookshelf` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        author: "some author",
        comment_number: 42,
        date_added: ~U[2022-11-13 06:46:00Z],
        date_modified: ~U[2022-11-13 06:46:00Z],
        hn_id: 42,
        points: 42,
        post_url: "some post_url",
        title: "some title",
        virtual_path: "some virtual_path"
      })
      |> HnBookshelf.Bookshelf.create_post()

    post
  end
end
