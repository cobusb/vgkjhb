defmodule Vgkjhb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VgkjhbWeb.Telemetry,
      Vgkjhb.Repo,
      {DNSCluster, query: Application.get_env(:vgkjhb, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Vgkjhb.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Vgkjhb.Finch},
      # Start a worker by calling: Vgkjhb.Worker.start_link(arg)
      # {Vgkjhb.Worker, arg},
      # Start to serve requests, typically the last entry
      VgkjhbWeb.Endpoint,
     {Beacon, sites: [[site: :church_site, endpoint: VgkjhbWeb.Endpoint]]}
]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Vgkjhb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VgkjhbWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
