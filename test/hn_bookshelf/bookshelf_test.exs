defmodule HnBookshelf.BookshelfTest do
  use HnBookshelf.DataCase

  alias HnBookshelf.Bookshelf

  describe "post" do
    alias HnBookshelf.Bookshelf.Post

    import HnBookshelf.BookshelfFixtures

    @invalid_attrs %{hn_id: nil, post_url: nil, title: nil}

    test "list_post/0 returns all post" do
      post = post_fixture()
      assert Bookshelf.list_post() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Bookshelf.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{hn_id: 42, post_url: "some post_url", title: "some title"}

      assert {:ok, %Post{} = post} = Bookshelf.create_post(valid_attrs)
      assert post.hn_id == 42
      assert post.post_url == "some post_url"
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bookshelf.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{hn_id: 43, post_url: "some updated post_url", title: "some updated title"}

      assert {:ok, %Post{} = post} = Bookshelf.update_post(post, update_attrs)
      assert post.hn_id == 43
      assert post.post_url == "some updated post_url"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Bookshelf.update_post(post, @invalid_attrs)
      assert post == Bookshelf.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Bookshelf.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Bookshelf.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Bookshelf.change_post(post)
    end
  end
end
