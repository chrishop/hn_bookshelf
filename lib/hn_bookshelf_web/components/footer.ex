defmodule HnBookshelfWeb.Components.Footer do
  use Surface.Component

  def render(assigns) do
    ~F"""
    <div class="h-[2px] bg-hn-orange"></div>
    <div class="h-[10px] bg-hn-grey-1"></div>
    <div class="bg-hn-grey-1 font-hn text-[8pt] text-center">
      Guidelines | FAQ | Lists | API | Security | Legal | Apply to YC | Contact
    </div>
    <div class="bg-hn-grey-1 h-[15px]"></div>
    """
  end
end
