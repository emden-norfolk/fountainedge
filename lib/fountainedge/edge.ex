defmodule Fountainedge.Edge do
  @moduledoc """
  A graph edge directionally links two nodes together.

  Edges are fundamental to the concept of transitioning between
  nodes.

  [Graphviz](https://graphviz.org/)
  is used for presentation and ranking of graph nodes.
  See `Graphvix.Graph.add_edge/4`.
  """

  alias __MODULE__

  @enforce_keys [:id, :next]

  defstruct id: nil, next: nil, attributes: []

  def find(edges, %Edge{} = edge) do
    Enum.find(edges, fn e -> e == edge end)
  end

  def find(edges, id) do
    Enum.find(edges, fn edge -> edge.id == id end)
  end
end
