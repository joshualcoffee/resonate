defmodule Resonate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Resonate.Manager

  def start(_type, _args) do
    children = [
      Resonate.Manager,
      {DynamicSupervisor, strategy: :one_for_one, name: Resonate.DynamicSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Resonate.Supervisor]
    sup = Supervisor.start_link(children, opts)

    Manager.subscribe([
      {Resonate.TestApp.OtherConsumer, [:test, :moo]},
      {Resonate.TestApp.Consumer, [:moo]}
    ])

    sup
  end
end
