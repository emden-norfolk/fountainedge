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

  # Security warning: ensure all inputs to :os:cmd are sanitised.
  # TODO Think about https://hexdocs.pm/elixir/1.14/Path.html
  def rank(%Workflow{} = workflow, filename) do
    #port_dot = Port.open({:spawn, "dot -Tdot #{filename}.dot "}, [:binary])
    # port_gvpr = Port.open({:spawn, "gvpr -f rank.gvpr"}, [:binary])

    ranking = :os.cmd(:"dot -Tdot #{filename}.dot | gvpr -f rank.gvpr")
    |> to_string
    |> String.split("\n")
    |> Enum.map(fn line -> String.split line end)
    |> Enum.filter(fn row -> !Enum.empty? row end)
    |> Enum.map(fn row ->
      {id, _} = Integer.parse Enum.at(row, 1)
      {rank, _} = Integer.parse Enum.at(row, 2)
      node = Fountainedge.Node.find(workflow.schema.nodes, id)
      %{node | rank: rank}
    end)
    |> Enum.sort(&(&1.id < &2.id))

    put_in(workflow.schema.nodes, ranking)
  end

  defp vertices(graph, vertices, [node | nodes]) do

    # TODO Why is simple logic so difficult in Elixir?
    {label, attributes} = if node.type == :fork or node.type == :join do
      {
        nil,
        [
          id: node.id,
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
          id: node.id,
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
