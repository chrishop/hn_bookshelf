defmodule HnBookshelfWeb.FrontPage do
  use Surface.LiveView

  alias HnBookshelfWeb.Components.Nav
  alias HnBookshelfWeb.Components.Posts
  alias HnBookshelfWeb.Components.Footer

  def render(assigns) do
    ~F"""
    <Nav/>
    <Posts/>
    <Footer/>

    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
