defmodule HnBookshelfWeb.PageController do
  use HnBookshelfWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
