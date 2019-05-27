defmodule Fountainedge do
  @moduledoc """
  Documentation for Fountainedge.
  """

  alias __MODULE__, as: Workflow
  alias Fountainedge.{Edge, State, Node, Token}

  @fork Node.fork
  @join Node.join

  defstruct nodes: [], edges: [], states: []

  def transition workflow, edge do
    edge = Enum.find workflow.edges, fn e -> e == edge end
    state = Enum.find workflow.states, fn s -> s.id == edge.id end

    %Workflow{workflow | states: transition_state(workflow, edge, state)}
  end

  defp transition_state %Workflow{} = workflow, %Edge{} = edge, %State{} = state do
    states = Enum.reject workflow.states, fn s -> s == state end
    next_state = %State{state | id: edge.next}
    states = states ++ [next_state]

    node = Enum.find workflow.nodes, fn n -> n.id == edge.next end
    states = case node.type do
      @fork -> fork workflow, states, node, next_state
      @join -> join workflow
      _ -> states
    end
    #IO.inspect workflow.states

    states
  end

  defp fork workflow, states, node, next_state do
    edges = Enum.filter workflow.edges, fn e -> e.id == node.id end
    forked_states = Enum.reduce edges, [], fn edge, acc ->
      token = %Token{id: edge.id, token: edge.next}
      tokens = next_state.tokens ++ [token]
      [%State{next_state | tokens: tokens} | acc]
      |> Enum.reverse
    end
    states = Enum.reject states, fn s -> s.id == next_state.id end
    states ++ forked_states

    #Enum.map edges
  end

  defp join workflow do
    workflow
  end
end
