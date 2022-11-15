defmodule HnBookshelf.HnApiTest do
  use ExUnit.Case

  import Test.Support.Helper

  alias HnBookshelf.HnApi

  describe "get_items/1" do
    setup do
      bypass = Bypass.open()

      set_env(:hn_bookshelf, :hn_api_endpoint, localhost(bypass.port))

      bypass_expect(bypass,
        path: "/api/v1/items/1",
        resp_body_fixture: "/test/support/fixtures/item_1.json"
      )

      on_exit(fn -> Bypass.down(bypass) end)
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
