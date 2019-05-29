defmodule Fountainedge.Schema do
  @moduledoc """
  Documentation for Fountainedge.Schema.
  """
  @enforce_keys [:nodes, :edges]

  defstruct nodes: [], edges: []
end
