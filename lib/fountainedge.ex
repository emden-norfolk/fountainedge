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
    #edge = Enum.find workflow.edges, fn e -> e == edge end

    %Workflow{workflow | states: transition_state(workflow.states, workflow.schema, edge)}
  end

  defp advance states, schema do
    states
  end

  defp transition_state states, %Schema{} = schema, %Edge{} = edge do
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

  defp fork states, %Schema{} = schema, %Node{} = node, %State{} = next_state do
    edges = Enum.filter schema.edges, fn e -> e.id == node.id end
    forked_states = Enum.reduce edges, [], fn edge, acc ->
      token = %Token{id: edge.id, token: edge.next}
      tokens = next_state.tokens ++ [token]
      [%State{next_state | tokens: tokens} | acc]
      |> advance(schema)
      |> Enum.reverse
    end
    states = Enum.reject states, fn s -> s.id == next_state.id end
    states ++ forked_states
  end

  defp join workflow do
    workflow
  end
end
