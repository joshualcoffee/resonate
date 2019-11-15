defmodule Resonate.Test.Event do
  @moduledoc false
  alias Resonate.Store
  alias Resonate.Event
  use ExUnit.Case, async: true

  setup do
    store = start_supervised!(Store)
    %{store: store}
  end

  test "deleting event from ets table" do
    event = %Event{id: "test"}
    Store.put(event)
    assert Store.get("test") == {:ok, event}
    Event.complete(event)
    assert Store.get("test") == {:error, :no_event_found}
  end
end
