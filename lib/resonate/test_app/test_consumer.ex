defmodule Resonate.TestApp.Consumer do
  use Resonate.Manager.BaseConsumer, rate_limit: 5000, demand: 10

  def handle_event({:moo, _}) do
    IO.inspect("moo was called from other consumer")
    :timer.sleep(200)
  end
end

# alias Resonate.Event
# alias Resonate.Manager
# event = %Event{data: "moo", event: :moo}
# for i <- 1..50, do: Manager.broadcast(event)
