defmodule Resonate.Manager.AsyncConsumer do
  defmacro __using__(args) do
    quote do
      use ConsumerSupervisor
      alias Resonate.Manager.Worker

      def start_link(arg) do
        ConsumerSupervisor.start_link(__MODULE__, arg)
      end

      def init(producer) do
        children = [
          %{
            id: Worker,
            start: {Worker, :start_link, [&handle_event!(&1)]},
            restart: :transient
          }
        ]

        args = unquote(args)

        opts = [
          strategy: :one_for_one,
          subscribe_to: [
            {producer, min_demand: args[:min_demand], max_demand: args[:max_demand]}
          ]
        ]

        ConsumerSupervisor.init(children, opts)
      end
    end
  end
end
