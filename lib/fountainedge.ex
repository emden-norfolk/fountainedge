defmodule Fountainedge do
  @moduledoc """
  Documentation for Fountainedge.
  """

  alias __MODULE__, as: Workflow
  alias Fountainedge.{Schema, Edge, State, Node, Token}

  @fork Node.fork
  @join Node.join

  @enforce_keys [:schema, :states]

  defstruct schema: %Schema{nodes: [], edges: []}, states: []

  def transition %Workflow{} = workflow, %Edge{} = edge do
    %Workflow{workflow | states: transition(workflow.states, workflow.schema, edge)}
  end

  defp transition states, %Schema{} = schema, %Edge{} = edge do
    edge = Enum.find schema.edges, fn e -> e == edge end
    node = Enum.find schema.nodes, fn n -> n.id == edge.next end
    state = current_state states, edge
    next_state = %State{state | id: edge.next}

    states = Enum.reject(states, fn s -> s == state end) ++ [next_state]
    case node.type do
      @fork -> fork states, schema, node, next_state
      @join -> join states, schema, node
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
      tokens = next_state.tokens ++ [token]
      [%State{next_state | tokens: tokens} | acc]
    end

    Enum.reject(states, fn s -> s.id == next_state.id end) ++ forked_states
    |> fork_transition(schema, edges)
  end

  defp fork_transition states, %Schema{} = schema, [edge | edges] do
    transition(states, schema, edge)
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
    (states -- arrivals) ++ [%State{id: node.id, tokens: tokens}]
  end

  defp join_tokens tokens,  %Node{} = origin_node, [state | arrivals] do
    tokens ++ Enum.reject(state.tokens, fn t -> t.id == origin_node.id end)
    |> join_tokens(origin_node, arrivals)
  end

  defp join_tokens(tokens, %Node{} = _origin_node, []), do: tokens
end
