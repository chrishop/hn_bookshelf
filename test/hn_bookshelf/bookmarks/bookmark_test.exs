defmodule HnBookshelf.BookmarkTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  import Test.Support.Helper

  alias HnBookshelf.Bookmark

  def ddg_bookmarks() do
    ~s"""
    <!DOCTYPE NETSCAPE-Bookmark-file-1>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
    <Title>Bookmarks</Title>
    <H1>Bookmarks</H1>
    <DL><p>
      <DT><H3 ADD_DATE="1618844074" LAST_MODIFIED="1618844074" PERSONAL_TOOLBAR_FOLDER="true">DuckDuckGo Bookmarks</H3>
      <DL><p>
        <DT><A HREF="https://coronavirus.data.gov.uk/" ADD_DATE="1618844074" LAST_MODIFIED="1618844074">Daily summary | Coronavirus in the UK</A>
        <DT><A HREF="https://news.ycombinator.com/item?id=33503306" ADD_DATE="1618844074" LAST_MODIFIED="1618844074">An Animated Introduction to Elixir | Hacker News</A>
      </DL><p>
      <DT><H3 ADD_DATE="1618844074" LAST_MODIFIED="1618844074">DuckDuckGo Favorites</H3>
      <DL><p>
        <DT><A HREF="https://news.ycombinator.com/item?id=28692470" ADD_DATE="1618844074" LAST_MODIFIED="1618844074">Making Bracket Pair Colorization Faster | Hacker News</A>
      </DL><p>
    </DL><p>
    """
  end

  describe "parse/2" do
    test "only passes all bookmarks flattening all folders into one list" do
      parsed_bookmarks =
        ddg_bookmarks()
        |> Floki.parse_document!()
        |> Bookmark.parse_bookmarks()

      assert length(parsed_bookmarks) == 3

      assert %Bookmark{
               date_added: ~U[2021-04-19 14:54:34Z],
               last_modified: ~U[2021-04-19 14:54:34Z],
               link: %URI{
                 authority: "coronavirus.data.gov.uk",
                 fragment: nil,
                 host: "coronavirus.data.gov.uk",
                 path: "/",
                 port: 443,
                 query: nil,
                 scheme: "https",
                 userinfo: nil
               },
               title: "Daily summary | Coronavirus in the UK"
             } = List.first(parsed_bookmarks)
    end
  end

  describe "enrich_bookmarks/1" do
    setup do
      bypass = Bypass.open()

      set_env(:hn_bookshelf, :hn_api_endpoint, localhost(bypass.port))
      on_exit(fn -> Bypass.down(bypass) end)
      %{bypass: bypass}
    end

    test "when bookmark is a hn item", %{bypass: bypass} do
      bypass_expect(bypass,
        path: "/api/v1/items/1",
        resp_body_fixture: "/test/support/fixtures/item_1.json"
      )

      bookmark =
        Bookmark.new(%{
          title: "hn_title",
          link: URI.parse("https://news.ycombinator.com/item?id=1"),
          date_added: ~U[2022-11-15 06:10:39.354510Z],
          last_modified: ~U[2022-11-15 06:10:39.354522Z]
        })

      assert %{
               author: "pg",
               hn_id: 1,
               created_at: ~U[2006-10-09 18:21:51Z],
               date_added: ~U[2022-11-15 06:10:39.354510Z],
               last_modified: ~U[2022-11-15 06:10:39.354522Z],
               link: _link,
               points: 61,
               title: "Y Combinator",
               type: "story"
             } = Bookmark.enrich(bookmark)
    end

    test "when api call fails", %{bypass: bypass} do
      bypass_expect(bypass,
        path: "/api/v1/items/1",
        resp_body: "{}",
        status_code: 500
      )

      bookmark =
        Bookmark.new(%{
          title: "hn_title",
          link: URI.parse("https://news.ycombinator.com/item?id=1"),
          date_added: ~U[2022-11-15 06:10:39.354510Z],
          last_modified: ~U[2022-11-15 06:10:39.354522Z]
        })

      log =
        capture_log(fn ->
          assert %{
                   date_added: ~U[2022-11-15 06:10:39.354510Z],
                   last_modified: ~U[2022-11-15 06:10:39.354522Z],
                   link: _link,
                   title: "hn_title"
                 } = Bookmark.enrich(bookmark)
        end)

      assert log =~ "get_item/1 failed with reason:"
    end

    test "when bookmark is a non hn item" do
      # no call to hn api should be made

      bookmark =
        Bookmark.new(%{
          title: "some_non_hn_article",
          link: URI.parse("https://surface-ui.org/properties"),
          date_added: ~U[2022-11-15 06:10:39.354510Z],
          last_modified: ~U[2022-11-15 06:10:39.354522Z]
        })

      assert %{
               date_added: ~U[2022-11-15 06:10:39.354510Z],
               last_modified: ~U[2022-11-15 06:10:39.354522Z],
               link: _link,
               title: "some_non_hn_article"
             } = Bookmark.enrich(bookmark)
    end

    test "when hacker news item has no id" do
      # no call to hn api should be made

      bookmark =
        Bookmark.new(%{
          title: "hn_title",
          link: URI.parse("https://news.ycombinator.com/item"),
          date_added: ~U[2022-11-15 06:10:39.354510Z],
          last_modified: ~U[2022-11-15 06:10:39.354522Z]
        })

      assert %{
               date_added: ~U[2022-11-15 06:10:39.354510Z],
               last_modified: ~U[2022-11-15 06:10:39.354522Z],
               link: _link,
               title: "hn_title"
             } = Bookmark.enrich(bookmark)
    end
  end

  describe "merge_duplicates/1" do
    test "can parse single hn bookmark" do
      hn_bookmark = %{
        title: "hn_bookmark",
        hn_id: 1234,
        author: "hn_chris",
        points: 42,
        link: URI.parse("https://example.com"),
        date_addded: DateTime.now!("Etc/UTC"),
        last_modified: DateTime.now!("Etc/UTC")
      }

      Bookmark.merge_duplicates([hn_bookmark]) == hn_bookmark
    end

    # test "can parse single non hn bookmark" do
    # end

    # test "will merge hn & non hn bookmark with same link, hn values take precedence" do
    # end

    # test "will not merge bookmarks that don't have the same link" do
    # end
  end
end
