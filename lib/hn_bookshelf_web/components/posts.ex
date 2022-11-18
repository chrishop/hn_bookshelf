defmodule HnBookshelfWeb.Components.Posts do
  use Surface.Component

  alias HnBookshelfWeb.Components.Post

  prop posts, :list, required: true
  prop next_page, :string, default: 1

  def render(assigns) do
    ~F"""
    <div class="h-[10px] bg-hn-grey-1"></div>
    {#for {i, post} <- @posts}
      <Post post_no={i} post={post}/>
    {/for}
    <div class="h-[10px] bg-hn-grey-1"></div>
    <div class="bg-hn-grey-1 pl-8 font-hn text-[10pt]"><a href={@next_page}>More</a></div>
    <div class="h-[10px] bg-hn-grey-1"></div>
    """
  end
end
