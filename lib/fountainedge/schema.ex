defmodule Fountainedge.Schema do
  @moduledoc """
  The schema models the underlying stateless structure of
  a workflow as a graph consisting of nodes and edges.
  """

  @enforce_keys [:nodes, :edges]

  defstruct nodes: [], edges: []

  @typedoc """
  Schema structure.
  * `:nodes` - List of nodes.
  * `:edges` - List of edges.
  """

  @type t :: %__MODULE__{
    nodes: list(Fountainedge.Node.t()),
    edges: list(Fountainedge.Edge.t())
  }
end
