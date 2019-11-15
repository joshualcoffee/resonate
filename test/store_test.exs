defmodule Resonate.Test.Store do
  @moduledoc false
  alias Resonate.Store
  alias Resonate.Event
  use ExUnit.Case, async: true

  setup do
    store = start_supervised!(Store)
    %{store: store}
  end

  test "inserts the event in to the ETS table" do
    event = %Event{id: "test"}
    assert {:ok, event} == Store.put(event)
  end

  test "retrieves event from ETS table" do
    event = %Event{id: "test"}
    Store.put(event)
    assert Store.get("test") == {:ok, event}
  end

  test "when event does not exist in ETS table" do
    assert Store.get("test") == {:error, :no_event_found}
  end

  test "deleting event from ets table" do
    event = %Event{id: "test"}
    Store.put(event)
    assert Store.get("test") == {:ok, event}
    Store.delete(event)
    assert Store.get("test") == {:error, :no_event_found}
  end
end
