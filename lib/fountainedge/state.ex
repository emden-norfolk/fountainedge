defmodule Fountainedge.State do
  @moduledoc """
  Tracks the current stateful progression of the workflow.
  """

  @enforce_keys [:id]

  defstruct id: nil, tokens: []
end
