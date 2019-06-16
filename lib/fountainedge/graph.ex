defmodule Fountainedge.Graph do
  @moduledoc """
  Documentation for Fountainedge.Graph.
  """

  alias Graphvix.Graph
  alias Fountainedge, as: Workflow

  def graph(%Workflow{} = workflow) do
    graph = Graph.new()
    {graph, vertices} = vertices(graph, [], workflow.schema.nodes)
    edges(graph, vertices, workflow.schema.edges)
  end

  defp vertices(graph, vertices, [node | nodes]) do
    {graph, vertex_id} = Graph.add_vertex(graph, Integer.to_string(node.id))
    vertices(graph, [{node.id, vertex_id}] ++ vertices, nodes)
  end

  defp vertices(graph, vertices, []), do: {graph, vertices}

  defp edges(graph, vertices, [edge | edges]) do
    {_, current} = List.keyfind(vertices, edge.id, 0)
    {_, next} = List.keyfind(vertices, edge.next, 0)

    {graph, _edge_id} = Graph.add_edge(graph, current, next)
    edges(graph, vertices, edges)
  end

  defp edges(graph, _vertices, []), do: graph
end
