defmodule Resonate.Manager.SyncConsumer do
  defmacro __using__(args) do
    quote do
      @args unquote(args)
      use GenStage

      def start_link(arg) do
        GenStage.start_link(__MODULE__, arg)
      end

      def init(producer) do
        {:consumer, nil, subscribe_to: [producer]}
      end

      def handle_subscribe(:producer, _opts, from, _) do
        send(self(), :ask)
        {:manual, from}
      end

      def handle_info(:ask, producer) do
        GenStage.ask(producer, @args[:demand])
        Process.send_after(self(), :ask, @args[:rate_limit])

        {:noreply, [], producer}
      end

      def handle_events([event | events], from, producer) do
        handle_event!(event)
        handle_events(events, from, producer)
        {:noreply, [], producer}
      end

      def handle_events([], _, producer) do
        {:noreply, [], producer}
      end
    end
  end
end
