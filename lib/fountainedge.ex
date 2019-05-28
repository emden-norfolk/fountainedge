defmodule Fountainedge do
  @moduledoc """
  Documentation for Fountainedge.
  """

  alias __MODULE__, as: Workflow
  alias Fountainedge.{Schema, Edge, State, Node, Token}

  @fork Node.fork
  @join Node.join

  defstruct schema: %Schema{}, states: []

  def transition %Workflow{} = workflow, %Edge{} = edge do
    %Workflow{workflow | states: move(workflow.states, workflow.schema, edge)}
  end

  defp move states, %Schema{} = schema, %Edge{} = edge do
    edge = Enum.find schema.edges, fn e -> e == edge end
    state = state states, edge
    states = Enum.reject states, fn s -> s == state end
    next_state = %State{state | id: edge.next}
    states = states ++ [next_state]

    node = Enum.find schema.nodes, fn n -> n.id == edge.next end
    states = case node.type do
      @fork -> fork states, schema, node, next_state
      @join -> join states, schema
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
    fork move(states, schema, edge), schema, edges
  end

  defp fork(states, %Schema{} = _schema, []), do: states

  defp join states, schema do nil
    states
  end
end
