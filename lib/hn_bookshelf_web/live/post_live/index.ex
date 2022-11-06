defmodule HnBookshelfWeb.PostLive.Index do
  use HnBookshelfWeb, :live_view

  alias HnBookshelf.Bookshelf
  alias HnBookshelf.Bookshelf.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :post_collection, list_post())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Bookshelf.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Post")
    |> assign(:post, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Bookshelf.get_post!(id)
    {:ok, _} = Bookshelf.delete_post(post)

    {:noreply, assign(socket, :post_collection, list_post())}
  end

  defp list_post do
    Bookshelf.list_post()
  end
end
