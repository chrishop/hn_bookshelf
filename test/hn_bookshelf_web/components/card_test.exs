defmodule HnBookshelfWeb.Components.CardTest do
  use HnBookshelfWeb.ConnCase, async: true
  use Surface.LiveViewTest

  catalogue_test HnBookshelfWeb.Card
end
