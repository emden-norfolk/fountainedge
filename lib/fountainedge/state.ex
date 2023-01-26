defmodule Fountainedge.State do
  @moduledoc """
  Tracks the current progression of the workflow (stateful.)

  `Fountainedge.Workflow` saves its status in a state list.
  Each active node receives a state. In linear mode, only one state is in the state list.
  Upon leaving a forking node, a state is created with a unique token for each out edge.
  Nested forks will result in multiple tokens being carried.
  """

  @enforce_keys [:id]

  defstruct id: nil, tokens: []

  @typedoc """
  Workflow status structure.
  * `:id` - Identifier of the active `Fountainedge.Node`.
  * `:tokens` - List of tokens carried by the active node.
  """

  @type t :: %__MODULE__{
    id: integer,
    tokens: list(Fountainedge.Token.t())
  }
end
