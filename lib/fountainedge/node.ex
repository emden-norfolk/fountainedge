defmodule Fountainedge.Node do
  @moduledoc """
  A graph node (also known as a vertex.)

  [Graphviz](https://graphviz.org/)
  is used for presentation and ranking of graph nodes.
  See `Graphvix.Graph.add_vertex/3`.
  """

  @enforce_keys [:id]

  defstruct id: nil, type: :normal, join: nil, label: nil, rank: nil, attributes: []

  def find(nodes, id) do
    Enum.find(nodes, fn node -> node.id == id end)
  end
end
