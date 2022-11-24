defmodule HnBookshelfWeb.FrontPage do
  use Surface.LiveView

  alias HnBookshelfWeb.Components.Nav
  alias HnBookshelfWeb.Components.Posts
  alias HnBookshelfWeb.Components.Footer

  def render(assigns) do
    ~F"""
    <Nav/>
    <Posts posts={@posts} next_page={@next_page}/>
    <Footer/>

    """
  end

  def mount(params, _session, socket) do
    page_no = get_page_no(params)
    folder = get_folder(params)
    posts = fetch_page_posts(folder, page_no)

    socket =
      socket
      |> assign(:folder, folder)
      |> assign(:page_no, page_no)
      |> assign(:next_page, next_page(folder, page_no))
      |> assign(:posts, posts)

    {:ok, socket}
  end

  def handle_params(params, _, socket) do
    page_no = get_page_no(params)
    folder = get_folder(params)
    posts = fetch_page_posts(folder, page_no)

    socket =
      socket
      |> assign(:folder, folder)
      |> assign(:page_no, page_no)
      |> assign(:next_page, next_page(folder, page_no))
      |> assign(:posts, posts)

    {:noreply, socket}
  end

  def handle_event("to_" <> folder, %{"id" => id}, socket) do
    IO.inspect(folder, label: "FOLDER")
    page_folder = socket.assigns.folder
    page_no = socket.assigns.page_no

    update_folder(id, folder) |> IO.inspect()

    posts = fetch_page_posts(page_folder, page_no)

    socket =
      socket
      |> assign(:posts, posts)

    {:noreply, socket}
  end

  def handle_event(_event, _unsigned_params, socket) do
    {:no_reply, socket}
  end

  defp get_page_no(params) do
    Map.get(params, "page_no", "1")
    |> Integer.parse()
    |> case do
      {i, _rem} when is_integer(i) -> i
      # defaults to 1
      :error -> 1
    end
  end

  defp get_folder(params) do
    Map.get(params, "folder", "new")
  end

  defp update_folder(id, folder) do
    post = HnBookshelf.Bookshelf.get_post!(id)

    HnBookshelf.Bookshelf.update_folder(post, folder)
  end

  defp next_page(folder, current_page) do
    "/posts/page/#{folder}/#{current_page + 1}"
  end

  defp fetch_page_posts(folder, page_no, post_per_page \\ 30) do
    numbers = page_post_numbers(page_no, post_per_page)

    posts =
      case folder do
        "new" ->
          HnBookshelf.Bookshelf.get_post_page(page_no, nil, post_per_page)

        folder ->
          HnBookshelf.Bookshelf.get_post_page(page_no, folder, post_per_page)
      end

    posts_view = Enum.map(posts, &post_view/1)

    Enum.zip(numbers, posts_view)
  end

  @spec page_post_numbers(number, integer) :: list
  defp page_post_numbers(page_no, post_per_page) do
    first_page_post_no = 1 + (page_no - 1) * post_per_page

    Enum.map(0..post_per_page, fn page_post_no -> first_page_post_no + page_post_no end)
  end

  defp post_view(post) do
    hash = :erlang.phash2(post)

    post
    |> Map.from_struct()
    |> Map.put(:site_url, site_url(post.post_url))
    |> Map.put(:author, fallback_author(post.author, hash))
    |> Map.put(:points, fallback_points(post.points, hash))
    |> Map.put(:comment_number, fallback_comment_no(post.comment_number, hash))
    |> Map.put(:comment_link, comment_link(post.hn_id))
  end

  defp site_url(post_url) do
    post_uri =
      post_url
      |> URI.parse()

    post_uri.host
  end

  defp fallback_author(nil, hash) do
    authors = ["hugh_jass", "mike_hawk", "lee_king", "symr_cox", "gene_attel"]
    i = rem(hash, length(authors))

    Enum.at(authors, i)
  end

  defp fallback_author(author, _hash), do: author

  defp fallback_points(nil, hash), do: rem(hash, 200)
  defp fallback_points(points, _hash), do: points

  defp fallback_comment_no(nil, hash), do: rem(hash, 200)
  defp fallback_comment_no(comment_no, _hash), do: comment_no

  defp comment_link(nil), do: ""
  defp comment_link(hn_id), do: "https://news.ycombinator.com/item?id=#{hn_id}"
end
