defmodule Fountainedge do
  @moduledoc """
  Workflow engine.

  A basic understanding of graph theory
  would elucidate an intuitive grasp of this package.
  """

  alias Fountainedge.{Workflow, Schema, Edge, State, Node, Token}

  @doc """
  Transition between nodes along an edge.

  The current nodes are tracked as a state, and parallel
  processess are tracked using tokens.

  A valid out edge must be given.

  The following example will transition along the edge from node 1 to node 2, provided
  that it is a valid out edge given the current status of the workflow:

      workflow = Fountainedge.transition(workflow, %Edge{id: 1, next: 2})
  """
  @spec transition(Workflow.t(), Edge.t()) :: Workflow.t()
  def transition %Workflow{} = workflow, %Edge{} = edge do
    edge = Edge.find(out_edges(workflow), edge)

    if edge == nil do
      raise "Invalid out edge given for transition."
    end

    %Workflow{workflow | states: transition(workflow.states, workflow.schema, edge)}
  end

  defp transition(states, %Schema{} = schema, %Edge{} = edge) do
    node = Node.find(schema.nodes, edge.next)
    state = current_state states, edge
    next_state = %State{state | id: edge.next}

    states = [next_state | Enum.reject(states, fn s -> s == state end)]
    case node.type do
      :fork -> fork states, schema, node, next_state
      :join -> join states, schema, node
      _ -> states
    end
  end

  defp current_state states, %Edge{} = edge do
    Enum.find(states, fn state ->
      state.id == edge.id and Enum.find state.tokens, fn token -> token.token == edge.next end
    end) || Enum.find states, fn state -> state.id == edge.id end
  end

  defp fork states, %Schema{} = schema, %Node{} = node, %State{} = next_state do
    edges = Enum.filter schema.edges, fn e -> e.id == node.id end
    forked_states = Enum.reduce edges, [], fn edge, acc ->
      token = %Token{id: edge.id, token: edge.next}
      tokens = [token | next_state.tokens]
      [%State{next_state | tokens: tokens} | acc]
    end

    Enum.reject(states, fn s -> s.id == next_state.id end) ++ forked_states
    |> fork_transition(schema, edges)
  end

  defp fork_transition(states, %Schema{} = schema, [edge | edges]) do
    states
    |> transition(schema, edge)
    |> fork_transition(schema, edges)
  end

  defp fork_transition(states, %Schema{} = _schema, []), do: states

  defp join states, %Schema{} = schema, %Node{} = node do
    origin_node = Enum.find schema.nodes, fn n -> n.join == node.id end
    branches = Enum.count schema.edges, fn e -> e.id == origin_node.id end
    arrivals = Enum.filter states, fn s ->
      s.id == node.id and Enum.any? s.tokens, fn t -> t.id == origin_node.id end
    end

    if branches == Enum.count arrivals do
      join_states(states, node, origin_node, arrivals)
      |> transition(schema, Enum.find(schema.edges, fn e -> e.id == node.id end))
    else
      states
    end
  end

  defp join_states states, %Node{} = node, %Node{} = origin_node, arrivals do
    tokens = Enum.uniq join_tokens [], origin_node, arrivals
    [%State{id: node.id, tokens: tokens} | states -- arrivals]
  end

  defp join_tokens tokens,  %Node{} = origin_node, [state | arrivals] do
    tokens ++ Enum.reject(state.tokens, fn t -> t.id == origin_node.id end)
    |> join_tokens(origin_node, arrivals)
  end

  defp join_tokens(tokens, %Node{} = _origin_node, []), do: tokens

  @doc """
  Returns a list of out edges that are valid transitions.

  An out edge is an edge leading out of any of the current nodes.

  Then pass the chosen edge into `transition/2`.
  """
  @spec out_edges(Workflow.t()) :: [Edge.t()] | []
  def out_edges(%Workflow{} = workflow) do
    gather_out_edges_state(workflow, [], workflow.states)
    |> Enum.uniq()
  end

  defp gather_out_edges_state(%Workflow{} = workflow, out_edges, [state | states]) do
    out_edges = out_edges(workflow, state) ++ out_edges
    gather_out_edges_state(workflow, out_edges, states)
  end

  defp gather_out_edges_state(%Workflow{} = _workflow, out_edges, []), do: out_edges

  defp out_edges(%Workflow{} = workflow, %State{} = state) do
    edges = Enum.filter(workflow.schema.edges, fn edge -> edge.id == state.id end)
    gather_out_edges(workflow, [], edges)
  end

  defp gather_out_edges(%Workflow{} = workflow, out_edges, [edge | edges]) do
    node = Node.find(workflow.schema.nodes, edge.id)

    gather_out_edges(workflow, (case node.type do
      :join -> out_edges
      _ -> [edge | out_edges]
    end), edges)
  end

  defp gather_out_edges(%Workflow{} = _workflow, out_edges, []), do: out_edges

  @doc """
  Returns a list of out edge nodes that are valid transitions.

  Same as `out_edges/1`, but with the nodes resolved also for convenience.
  """
  @spec out_edge_nodes(Workflow.t()) :: [{Edge.t(), Node.t(), Node.t()}] | []
  def out_edge_nodes(%Workflow{} = workflow) do
    out_edges(workflow)
    |> Enum.map(fn edge ->
      {
        edge,
        Node.find(workflow.schema.nodes, edge.id),
        Node.find(workflow.schema.nodes, edge.next)
      }
    end)
  end
end
