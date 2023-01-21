defmodule Fountainedge.OutEdge do
  @moduledoc """
  Defines a valid out edge.
  """

  @enforce_keys [:edge]

  defstruct edge: nil, disabled: false
end
