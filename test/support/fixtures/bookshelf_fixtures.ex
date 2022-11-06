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
        hn_id: 42,
        post_url: "some post_url",
        title: "some title"
      })
      |> HnBookshelf.Bookshelf.create_post()

    post
  end
end
