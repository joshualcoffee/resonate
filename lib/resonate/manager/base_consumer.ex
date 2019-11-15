defmodule Resonate.Manager.BaseConsumer do
  alias Resonate.Event
  alias Resonate.Manager.{AsyncConsumer, SyncConsumer}
  @callback handle_event(Event.t()) :: any()
  defmacro __using__(args) do
    opts = [min_demand: 5, max_demand: 10, demand: 10, rate_limit: 500] |> Keyword.merge(args)

    quote do
      @args unquote(opts)
      @behaviour Resonate.Manager.BaseConsumer
      if is_nil(unquote(args)[:rate_limit]) do
        use AsyncConsumer, min_demand: @args[:min_demand], max_demand: @args[:max_demand]
      else
        use SyncConsumer, rate_limit: @args[:rate_limit], demand: @args[:demand]
      end

      def handle_event!(event) do
        try do
          handle_event(event)
        rescue
          FunctionClauseError -> :ok
        end
      end

      def handle_event(_), do: :ok
      defoverridable handle_event: 1
    end
  end
end
