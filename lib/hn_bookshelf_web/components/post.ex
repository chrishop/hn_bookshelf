defmodule HnBookshelfWeb.Components.Post do
  use Surface.Component

  alias HnBookshelfWeb.Endpoint
  alias HnBookshelfWeb.Router.Helpers, as: Routes

  prop post_no, :string, required: true

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
            <a>Apple Execs on iMessage for Android (2013)</a>
          </div>
          <div class="self-end text-[8pt] font-hn text-hn-grey-2 ml-1">
            <a>(twitter.com/techemails)</a>
          </div>
        </div>
      </div>
      <div class="text-[7pt] font-hn text-hn-grey-2 ml-8">
          94 points by mfiguiere 1 hour ago | hide | 85 comments
      </div>
      <div class="h-[5px]"></div>
    </div>
    """
  end

  def upvote() do
    Routes.static_path(Endpoint, "/images/hn_upvote_arrow.gif")
  end
end
