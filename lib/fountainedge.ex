defmodule Fountainedge do
  @moduledoc """
  Documentation for Fountainedge.
  """

  alias __MODULE__, as: Workflow
  alias Fountainedge.{Schema, Edge, State, Node, Token}

  @fork Node.fork
  #@join Node.join

  defstruct schema: %Schema{}, states: []

  def transition %Workflow{} = workflow, %Edge{} = edge do
    #edge = Enum.find workflow.edges, fn e -> e == edge end

    %Workflow{workflow | states: move(workflow.states, workflow.schema, edge)}
  end

  defp move states, %Schema{} = schema, %Edge{} = edge do
    state = Enum.find states, fn s -> s.id == edge.id end
    states = Enum.reject states, fn s -> s == state end
    next_state = %State{state | id: edge.next}
    states = states ++ [next_state]

    node = Enum.find schema.nodes, fn n -> n.id == edge.next end
    states = case node.type do
      @fork -> fork states, schema, node, next_state
      #@join -> join
      _ -> states
    end
    #IO.inspect workflow.states

    states
  end

  def move states, %Schema{} = schema, edges do
    states = move
  end

  defp fork states, %Schema{} = schema, %Node{} = node, %State{} = next_state do
    edges = Enum.filter schema.edges, fn e -> e.id == node.id end
    forked_states = Enum.reduce edges, [], fn edge, acc ->
      token = %Token{id: edge.id, token: edge.next}
      tokens = next_state.tokens ++ [token]
      [%State{next_state | tokens: tokens} | acc]
    end

    states = Enum.reject states, fn s -> s.id == next_state.id end
    states ++ forked_states

    Enum.filter

    Enum.reduce forked_states, [], fn state, acc ->
      edge = Enum.find(schema.edges, fn e -> e.id == state.id end)
      [state | acc]
    end
  end

  #defp join workflow do
end
