defmodule Fountainedge do
  @moduledoc """
  Documentation for Fountainedge.
  """

  alias __MODULE__, as: Workflow
  alias Fountainedge.{Edge, State, Node}

  defstruct nodes: [], edges: [], states: []

  def transition workflow, edge do
    edge = Enum.find workflow.edges, fn e -> e == edge end
    state = Enum.find workflow.states, fn s -> s.id == edge.id end

    transition_state workflow, edge, state
  end

  defp transition_state %Workflow{} = workflow, %Edge{} = edge, %State{} = state do
    states = Enum.reject workflow.states, fn s -> s == state end
    next_state = %State{state | id: edge.next}
    workflow = %Workflow{workflow | states: states ++ [next_state]}

    node = Enum.find workflow.nodes, fn n -> n.id == edge.next end
    if node.type == Node.fork do
      Enum.filter workflow.edges, fn e -> e.id == node.id end
    end

    workflow
  end
end
