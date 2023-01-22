defmodule Fountainedge.OutEdge do
  @moduledoc """
  Defines a valid out edge.
  """

  @enforce_keys [:edge]

  # TODO remove this class entirely?
  # How useful is a disabled out edge?
  # Could be more confusing than anything.
  # Check client usage. Deprecate in version 1?
  defstruct edge: nil, disabled: false
end
