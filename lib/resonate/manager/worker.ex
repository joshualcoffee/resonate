defmodule Resonate.Manager.Worker do
  def start_link(f, event) do
    Task.start_link(fn ->
      f.(event)
    end)
  end
end
