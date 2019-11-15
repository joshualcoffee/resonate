defmodule Resonate.Manager do
  use GenServer
  alias GenStage
  alias Resonate.Manager.Producer

  def init(_) do
    {:ok, []}
  end

  def subscribe(consumers) when is_list(consumers) do
    for(c <- consumers, do: subscribe(c))
  end

  def subscribe({consumer, events}) do
    subscribe(consumer, events)
  end

  def subscribe(consumer), do: subscribe(consumer, [])

  def subscribe(consumer, events) do
    producer_name =
      ((consumer |> to_string) <> "Producer") |> String.replace(".", "") |> String.to_atom()

    parent =
      DynamicSupervisor.start_child(
        Resonate.DynamicSupervisor,
        %{
          id: producer_name,
          start: {Resonate.Manager.Producer, :start_link, [producer_name]},
          restart: :transient
        }
      )

    GenServer.cast(__MODULE__, {:add, {producer_name, events}})

    child = DynamicSupervisor.start_child(Resonate.DynamicSupervisor, {consumer, producer_name})
    {parent, child}
  end

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_cast({:add, producer}, producers) do
    items = [producer | producers]
    {:noreply, items}
  end

  def broadcast(event) do
    GenServer.call(__MODULE__, {:broadcast, event})
  end

  def handle_call({:broadcast, %{event: type} = event}, _from, producers) do
    for {producer, events} <- producers do
      broadcast? =
        cond do
          length(events) > 0 && events |> Enum.member?(type) ->
            true

          length(events) == 0 ->
            true

          true ->
            false
        end

      if broadcast?, do: Producer.broadcast(producer, {type, event})
    end

    {:reply, :ok, producers}
  end

  def handle_call({:broadcast, _}, _, producers) do
    {:reply, {:error, :invalid_event}, producers}
  end
end
