defmodule HnBookshelf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      HnBookshelf.Repo,
      # Start the Telemetry supervisor
      HnBookshelfWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HnBookshelf.PubSub},
      # Start the Endpoint (http/https)
      HnBookshelfWeb.Endpoint,
      # Start a worker by calling: HnBookshelf.Worker.start_link(arg)
      # {HnBookshelf.Worker, arg}
      {Task.Supervisor, name: HnBookshelf.TaskSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HnBookshelf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HnBookshelfWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
