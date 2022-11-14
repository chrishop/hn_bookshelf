defmodule HnBookshelf.BookshelfTest do
  use HnBookshelf.DataCase

  alias HnBookshelf.Bookshelf

  describe "post" do
    alias HnBookshelf.Bookshelf.Post

    import HnBookshelf.BookshelfFixtures

    @invalid_attrs %{
      author: nil,
      comment_number: nil,
      date_added: nil,
      date_modified: nil,
      hn_id: nil,
      points: nil,
      post_url: nil,
      title: nil,
      virtual_path: nil
    }

    test "list_post/0 returns all post" do
      post = post_fixture()
      assert Bookshelf.list_post() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Bookshelf.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{
        author: "some author",
        comment_number: 42,
        date_added: ~U[2022-11-13 06:46:00Z],
        date_modified: ~U[2022-11-13 06:46:00Z],
        hn_id: 42,
        points: 42,
        post_url: "some post_url",
        title: "some title",
        virtual_path: "some virtual_path"
      }

      assert {:ok, %Post{} = post} = Bookshelf.create_post(valid_attrs)
      assert post.author == "some author"
      assert post.comment_number == 42
      assert post.date_added == ~U[2022-11-13 06:46:00Z]
      assert post.date_modified == ~U[2022-11-13 06:46:00Z]
      assert post.hn_id == 42
      assert post.points == 42
      assert post.post_url == "some post_url"
      assert post.title == "some title"
      assert post.virtual_path == "some virtual_path"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bookshelf.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()

      update_attrs = %{
        author: "some updated author",
        comment_number: 43,
        date_added: ~U[2022-11-14 06:46:00Z],
        date_modified: ~U[2022-11-14 06:46:00Z],
        hn_id: 43,
        points: 43,
        post_url: "some updated post_url",
        title: "some updated title",
        virtual_path: "some updated virtual_path"
      }

      assert {:ok, %Post{} = post} = Bookshelf.update_post(post, update_attrs)
      assert post.author == "some updated author"
      assert post.comment_number == 43
      assert post.date_added == ~U[2022-11-14 06:46:00Z]
      assert post.date_modified == ~U[2022-11-14 06:46:00Z]
      assert post.hn_id == 43
      assert post.points == 43
      assert post.post_url == "some updated post_url"
      assert post.title == "some updated title"
      assert post.virtual_path == "some updated virtual_path"
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
