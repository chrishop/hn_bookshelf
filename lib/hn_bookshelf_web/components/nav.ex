defmodule HnBookshelfWeb.Components.Nav do
  use Surface.Component

  slot default, required: true

  # slot title

  # slot trunc_link

  # slot link

  # slot points

  # slot author

  # slot comment_number

  def render(assigns) do
    ~F"""
    <h1 class= "font-hn text-hn-grey-2"><#slot/></h1>
    """
  end
end
