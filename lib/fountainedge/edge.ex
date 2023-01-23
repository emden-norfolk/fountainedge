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

  @doc """
  Find a matching edge in a list (used internally.)
  """
  def find(edges, %Edge{} = edge) do
    Enum.find(edges, fn e -> e.id == edge.id && e.next == edge.next end)
  end
end
