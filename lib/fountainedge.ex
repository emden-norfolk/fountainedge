defmodule Fountainedge do
  @moduledoc """
  Workflow engine.

  A basic understanding of graph theory
  would elucidate an intuitive grasp of this package.
  """

  # TODO Move most of this into a Workflow module.
  # This would be breaking compatibility, so only do this for version 1 release.

  alias __MODULE__, as: Workflow
  alias Fountainedge.{Schema, Edge, State, Node, Token, OutEdge}

  @enforce_keys [:schema, :states]

  defstruct schema: %Schema{nodes: [], edges: []}, states: []

  @doc """
  Transition between nodes along an edge.

  The current nodes are tracked as a state, and parallel
  processess are tracked using tokens.

  A valid out edge must be given.
  """
  def transition %Workflow{} = workflow, %Edge{} = edge do
    %Workflow{workflow | states: transition(workflow.states, workflow.schema, edge)}
  end

  defp transition(states, %Schema{} = schema, %Edge{} = edge) do
    edge = Edge.find(schema.edges, edge)
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
      |> transition(schema, Edge.find(schema.edges, node.id))
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

  The out edge is an edge leading out of a current node.

  Then pass the chosen edge into `Fountainedge.transition/2`.
  """
  def out_edges(%Workflow{} = workflow) do
    gather_out_edges_state(workflow, [], workflow.states)
    |> Enum.uniq()
  end

  defp gather_out_edges_state(%Workflow{} = workflow, out_edges, [state | states]) do
    out_edges = out_edges(workflow, state) ++ out_edges
    gather_out_edges_state(workflow, out_edges, states)
  end

  defp gather_out_edges_state(%Workflow{} = _workflow, out_edges, []), do: out_edges

  # TODO remove?
  # This has been made private. May be able to remove entirely?
  # No need to pass in state as a client, should be internal.
  defp out_edges(%Workflow{} = workflow, %State{} = state) do
    edges = Enum.filter(workflow.schema.edges, fn edge -> edge.id == state.id end)
    gather_out_edges(workflow, [], edges)
  end

  defp gather_out_edges(%Workflow{} = workflow, out_edges, [edge | edges]) do
    node = Node.find(workflow.schema.nodes, edge.id)

    disabled = case node.type do
      :join -> true
      _ -> false
    end

    out_edge = %OutEdge{edge: edge, disabled: disabled}
    gather_out_edges(workflow, [out_edge | out_edges], edges)
  end

  defp gather_out_edges(%Workflow{} = _workflow, out_edges, []), do: out_edges
end
