defmodule Resonate.TestApp.OtherConsumer do
  use Resonate.Manager.BaseConsumer, min_demand: 1, max_demand: 2

  def handle_event({:moo, _}) do
    IO.inspect("moo was called")
    :timer.sleep(1000)
  end

  def handle_event({:test, _}) do
    IO.inspect("test wasll called")
    :timer.sleep(200)
  end
end
