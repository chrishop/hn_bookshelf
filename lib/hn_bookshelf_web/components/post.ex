defmodule HnBookshelfWeb.Components.Post do
  use Surface.Component

  alias HnBookshelfWeb.Endpoint
  alias HnBookshelfWeb.Router.Helpers, as: Routes

  prop post_no, :integer, required: true
  # should change the post into its component parts
  prop post, :any, required: true

  def render(assigns) do
    ~F"""
    <div class="bg-hn-grey-1 flex flex-col pl-2">
      <div class="flex flex-col">
        <div class="flex flex-row">
          <div class="text-hn-grey-2 text-[10pt] font-hn">{@post_no}.</div>
          <div class="self-center ml-1">
            <img class="w-[10px] h-[10px]" src={upvote()}/>
          </div>
          <div class="text-[10pt] font-hn ml-1">
            <a href={@post.post_url}>{@post.title}</a>
          </div>
          <div class="self-end text-[8pt] font-hn text-hn-grey-2 ml-1">
            <a href={@post.post_url}>({@post.site_url})</a>
          </div>
        </div>
      </div>
      <div class="text-[7pt] font-hn text-hn-grey-2 ml-8">
          {@post.points} points by {@post.author} 1 hour ago | hide | {@post.comment_number} <a href={@post.comment_link}>comments</a> | <a phx-click="to_now" phx-value-id={@post.id}>now</a> | <a phx-click="to_keep" phx-value-id={@post.id}>keep</a> | <a phx-click="to_bin" phx-value-id={@post.id}>bin</a>
      </div>
      <div class="h-[5px]"></div>
    </div>
    """
  end

  def upvote() do
    Routes.static_path(Endpoint, "/images/hn_upvote_arrow.gif")
  end
end
