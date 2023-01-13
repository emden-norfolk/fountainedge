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

    # TODO Why is simple logic so difficult in Elixir?
    {label, attributes} = if node.type == :fork or node.type == :join do
      {
        nil,
        [
          shape: "box",
          style: "filled",
          fillcolor: "black",
          height: 0.05,
          width: 1.5,
          fixedsize: "true",
        ]
      }
    else
      {
        node.label || Integer.to_string(node.id),
        [
          shape: "square",
        ]
      }
    end

    {graph, vertex_id} = Graph.add_vertex(graph, label, attributes)
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
