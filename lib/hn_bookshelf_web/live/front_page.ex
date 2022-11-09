defmodule HnBookshelfWeb.FrontPage do
  use Surface.LiveView

  alias HnBookshelfWeb.Components.Nav
  alias HnBookshelfWeb.Components.Post

  def render(assigns) do
    ~F"""
    <Nav/>
    <div class="h-[10px] bg-hn-grey-1"></div>
    {#for i <- 1..30}
      <Post post_no={i}/>
    {/for}
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
