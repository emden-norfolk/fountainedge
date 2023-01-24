defmodule Fountainedge.Graph do
  @moduledoc """
  Graphing functions.
  """

  alias Graphvix.Graph
  alias Fountainedge.Schema
  alias Fountainedge.Workflow

  @doc """
  Graphs a schema as a [UML](https://www.omg.org/spec/UML/)
  Activity Diagram using [Graphviz](https://graphviz.org/).

  If given a workflow, the graph will be decorated with stateful
  information such as the current node (or nodes.)
  """
  def graph(%Workflow{} = workflow) do
    graph(workflow.schema, workflow.states)
  end

  def graph(%Schema{} = schema) do
    graph(schema, [])
  end

  defp graph(%Schema{} = schema, states) do
    graph = Graph.new()
    {graph, vertices} = vertices(graph, states, [], schema.nodes)
    edges(graph, vertices, schema.edges)
  end

  defp vertices(graph, states, vertices, [node | nodes]) do
    {label, attributes} = if node.type in [:fork, :join] do
      {
        # TODO pass in default styles?
        nil,
        [
          id: node.id,
          shape: "box",
          style: "filled",
          fillcolor: "black",
          height: 0.1,
          width: 2,
          fixedsize: "true",
        ]
      }
    else
      {
        node.label || Integer.to_string(node.id),
        [
          id: node.id,
          shape: (if node.type in [:initial, :final], do: "oval", else: "box"),
          color: (if Enum.find(states, fn s -> s.id == node.id end), do: "red", else: "black")
        ]
      }
    end

    # Apply custom node attributes.
    attributes = attributes ++ node.attributes

    {graph, vertex_id} = Graph.add_vertex(graph, label, attributes)
    vertices(graph, states, [{node.id, vertex_id}] ++ vertices, nodes)
  end

  defp vertices(graph, _states, vertices, []), do: {graph, vertices}

  defp edges(graph, vertices, [edge | edges]) do
    {_, current} = List.keyfind(vertices, edge.id, 0)
    {_, next} = List.keyfind(vertices, edge.next, 0)

    {graph, _edge_id} = Graph.add_edge(graph, current, next, edge.attributes)
    edges(graph, vertices, edges)
  end

  defp edges(graph, _vertices, []), do: graph

  @doc """
  Ranks all nodes in a given schema.

  Will set the `rank` field on each `Fountainedge.Node` within the schema.

  Useful for determining backward and forward directions between two nodes.
  If the rank of the out edge node is less than the current node, then the
  direction is backwards. Otherwise, if greater, then the direction is forwards.

  [`dot`](https://graphviz.org/docs/layouts/dot/) creates hierarchical
  or layered drawings of directed graphs. A ranking algorithmn is used
  to determine this heirarchy. It may be useful to use these ranks
  when determining direction in a workflow. Call this function to
  calculate ranks per each node.
  """
  # Security warning: ensure all inputs to :os:cmd are sanitised.
  # TODO Think about https://hexdocs.pm/elixir/1.14/Path.html
  def rank(%Schema{} = schema, filename) do
    #port_dot = Port.open({:spawn, "dot -Tdot #{filename}.dot "}, [:binary])
    # port_gvpr = Port.open({:spawn, "gvpr -f rank.gvpr"}, [:binary])

    filename_rank_gvpr = to_string(:code.priv_dir(:fountainedge)) <> "/rank.gvpr"

    ranking = :os.cmd(:"dot -Tdot #{filename}.dot | gvpr -f #{filename_rank_gvpr}")
              |> to_string
              |> String.split("\n")
              |> Enum.map(fn line -> String.split line end)
              |> Enum.filter(fn row -> !Enum.empty? row end)
              |> Enum.map(fn row ->
                {id, _} = Integer.parse Enum.at(row, 1)
                {rank, _} = Integer.parse Enum.at(row, 2)
                node = Fountainedge.Node.find(schema.nodes, id)
                %{node | rank: rank}
              end)
              |> Enum.sort(&(&1.id < &2.id))

    put_in(schema.nodes, ranking)
  end

  def rank(%Workflow{} = workflow, filename) do
    %{workflow | schema: rank(workflow.schema, filename)}
  end
end
