defmodule HnBookshelfWeb.FrontPage do
  use Surface.LiveView

  alias HnBookshelfWeb.Components.Nav

  def render(assigns) do
    ~F"""
    <Nav>
      Hello There!
    </Nav>
    """
  end
end
