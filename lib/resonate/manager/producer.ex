defmodule Resonate.Manager.Producer do
  use GenStage

  @doc "Starts the broadcaster."
  def start_link(name) do
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  @doc "Sends an event and returns only after the event is dispatched."
  def broadcast(producer, event, timeout \\ 5000) do
    GenStage.call(producer, {:notify, event}, timeout)
  end

  @spec init(:ok) ::
          {:producer, {:queue.queue(any), 0}, [{:dispatcher, GenStage.BroadcastDispatcher}, ...]}
  def init(:ok) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_call({:notify, event}, from, {queue, pending_demand}) do
    GenStage.reply(from, :ok)
    queue = :queue.in(event, queue)
    dispatch_events(queue, pending_demand, [])
  end

  @spec handle_demand(number, {any, number}) :: {:noreply, [any], {any, any}}
  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end

  defp dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  defp dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        dispatch_events(queue, demand - 1, [event | events])

      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
