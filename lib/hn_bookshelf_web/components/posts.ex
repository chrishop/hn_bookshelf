defmodule HnBookshelfWeb.Components.Posts do
  use Surface.Component

  alias HnBookshelfWeb.Components.Post

  def render(assigns) do
    ~F"""
    <div class="h-[10px] bg-hn-grey-1"></div>
    {#for i <- 1..30}
      <Post post_no={i}/>
    {/for}
    <div class="h-[10px] bg-hn-grey-1"></div>
    <div class="bg-hn-grey-1 pl-8 font-hn text-[10pt]">More</div>
    <div class="h-[10px] bg-hn-grey-1"></div>
    """
  end
end
