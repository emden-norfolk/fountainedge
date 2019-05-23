defmodule Fountainedge do
  @moduledoc """
  Documentation for Fountainedge.
  """

  alias __MODULE__, as: Workflow
  alias Fountainedge.{Edge, State}

  defstruct nodes: [], edges: [], states: []

  def transition(workflow, edge) do
    edge = Enum.find(workflow.edges, fn e -> e == edge end)
    state  = Enum.find(workflow.states, fn s -> s.id == edge.id end)

    Workflow.update_state(workflow, edge, state)
  end

  def update_state(%Workflow{} = workflow, %Edge{} = edge, %State{} = state) do
    states = Enum.reject(workflow.states, fn s -> s == state end)
    %Workflow{workflow | states: states ++ [%State{state | id: edge.next}]}
  end
end
