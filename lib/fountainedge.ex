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
    state = state states, edge
    states = Enum.reject states, fn s -> s == state end
    next_state = %State{state | id: edge.next}
    states = states ++ [next_state]

    node = Enum.find schema.nodes, fn n -> n.id == edge.next end
    states = case node.type do
      @fork -> fork states, schema, node, next_state
      @join -> join states, schema, node
      _ -> states
    end

    states
  end

  defp state states, %Edge{} = edge do
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

    states = Enum.reject(states, fn s -> s.id == next_state.id end) ++ forked_states

    fork states, schema, edges
  end

  defp fork states, %Schema{} = schema, [edge | edges] do
    fork transition(states, schema, edge), schema, edges
  end

  defp fork(states, %Schema{} = _schema, []), do: states

  defp join states, %Schema{} = schema, %Node{} = node do
    origin_node = Enum.find schema.nodes, fn n -> n.join == node.id end
    branches = Enum.count schema.edges, fn e -> e.id == origin_node.id end
    arrivals = Enum.count states, fn s ->
      s.id == node.id and Enum.any? s.tokens, fn t -> t.id == origin_node.id end
    end

    if branches == arrivals do
      join states, node, origin_node
    else
      states
    end
  end

  defp join states, %Node{} = node, %Node{} = origin_node do
    states
  end
end
