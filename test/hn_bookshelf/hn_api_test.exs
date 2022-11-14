defmodule HnBookshelf.HnApiTest do
  use ExUnit.Case, async: true

  alias HnBookshelf.HnApi

  def set_env(app, key, new_value) do
    original_value = Application.get_env(app, key)
    Application.put_env(app, key, new_value)

    on_exit(fn -> Application.put_env(app, key, original_value) end)
  end

  def localhost(port) do
    "http://localhost:#{port}/api/v1"
  end

  describe "get_items/1" do
    setup do
      bypass = Bypass.open()

      set_env(:hn_bookshelf, :hn_api_endpoint, localhost(bypass.port))

      Bypass.expect_once(
        bypass,
        "GET",
        "api/v1/items/1",
        fn conn ->
          Plug.Conn.resp(
            conn,
            200,
            File.read!(File.cwd!() <> "/test/support/fixtures/item_1.json")
          )
        end
      )

      :ok
    end

    test "fetches info about post item from api" do
      {:ok, item} = HnApi.get_item(1)

      assert %{
               author: "pg",
               created_at: "2006-10-09T18:21:51.000Z",
               created_at_i: 1_160_418_111,
               id: 1,
               options: [],
               parent_id: nil,
               points: 61,
               story_id: nil,
               text: nil,
               title: "Y Combinator",
               type: "story",
               url: "http://ycombinator.com",
               children: _children_comments
             } = item
    end
  end
end
