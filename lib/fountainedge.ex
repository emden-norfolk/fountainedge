defmodule Fountainedge do
  @moduledoc """
  Documentation for Fountainedge.
  """

  alias __MODULE__, as: Workflow

  defstruct nodes: [], edges: [], states: []

  def transition(workflow, edge) do
    edge = Enum.find(workflow.edges, fn e -> e == edge end)
    state  = Enum.find(workflow.states, fn s -> s == edge.id end)

    Workflow.update_state(workflow, edge, state)
  end

  def update_state(workflow, edge, state) do
    workflow
  end
end
