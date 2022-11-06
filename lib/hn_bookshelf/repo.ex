defmodule HnBookshelf.Repo do
  use Ecto.Repo,
    otp_app: :hn_bookshelf,
    adapter: Ecto.Adapters.Postgres
end
