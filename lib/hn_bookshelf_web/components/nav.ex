defmodule HnBookshelfWeb.Components.Nav do
  use Surface.Component

  alias HnBookshelfWeb.Endpoint
  alias HnBookshelfWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~F"""
    <nav class="bg-hn-orange flex flex-row content-center place-items-center p-0.5">
      <div class="place-self-center  mr-1">
        <a href="/front_page"><img class="border border-white" src={hn_logo()}/></a>
      </div>
      <span class="inline-flex">
        <b class="mr-[10px] font-hn text-[10pt]">Hacker News</b>
        <p class="font-hn text-[10pt]"><a href="/posts/page/new/1">new</a> | <a href="/posts/page/now/1">now</a> | <a href="/posts/page/keep/1">keep</a> | <a href="/posts/page/bin/1">bin</a> | comments | ask | show | jobs | submit</p>
      </span>
      <div class="font-hn text-[10pt] ml-auto pr-1">
        login
      </div>
    </nav>
    """
  end

  def hn_logo() do
    Routes.static_path(Endpoint, "/images/y_combinator_logo.gif")
  end

  def upvote_arrow() do
    Routes.static_path(Endpoint, "/images/hn_upvote_arrow.gif")
  end
end
