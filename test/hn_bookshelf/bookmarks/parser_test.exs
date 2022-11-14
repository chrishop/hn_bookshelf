defmodule HnBookshelf.Bookmarks.ParserTest do
  use ExUnit.Case, async: true

  alias HnBookshelf.Bookmarks.Parser
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
        |> Parser.parse([])

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
end
