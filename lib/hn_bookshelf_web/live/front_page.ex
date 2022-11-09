defmodule HnBookshelfWeb.FrontPage do
  use Surface.LiveView

  alias HnBookshelfWeb.Components.Nav
  alias HnBookshelfWeb.Components.Post

  def render(assigns) do
    ~F"""
    <Nav/>
    <Post/>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
