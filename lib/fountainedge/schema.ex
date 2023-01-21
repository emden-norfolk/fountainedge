defmodule Fountainedge.Schema do
  @moduledoc """
  The schema models the underlying stateless structure of
  a workflow as a graph consisting of nodes and edges.
  """

  @enforce_keys [:nodes, :edges]

  defstruct nodes: [], edges: []
end
