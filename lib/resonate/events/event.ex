defmodule Resonate.Event do
  @moduledoc """
  Module is responsible for creating and interacting with events.
  The purpose of events is to provide a data sruct that can be passed to consumers.
  """

  defstruct [:data, :event]

  @type t :: %__MODULE__{
          data: any(),
          event: atom() | String.t()
        }
end
