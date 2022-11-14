defmodule HnBookshelf.Bookmark do
  @type t :: %__MODULE__{
          title: String.t(),
          link: URI.t(),
          date_added: DateTime.t(),
          last_modified: DateTime.t()
        }

  @enforce_keys [:title, :link, :date_added, :last_modified]
  defstruct [:title, :link, :date_added, :last_modified]

  def new(title, link, date_added, last_modified) do
    %__MODULE__{
      title: title,
      link: link,
      date_added: date_added,
      last_modified: last_modified
    }
  end

  def new(bookmark) when is_map(bookmark) do
    %__MODULE__{
      title: bookmark[:title],
      link: bookmark[:link],
      date_added: bookmark[:date_added],
      last_modified: bookmark[:last_modified]
    }
  end
end
