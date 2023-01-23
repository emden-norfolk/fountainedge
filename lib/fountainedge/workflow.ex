defmodule Fountainedge.Workflow do
  @moduledoc """
  The workflow is based on a `Fountainedge.Schema` and models
  the current state of the flowchart as a list of `Fountainedge.State`s.
  """

  alias Fountainedge.{Workflow, Schema, State}

  @enforce_keys [:schema, :states]

  defstruct schema: %Schema{nodes: [], edges: []}, states: []

  def initialize %Schema{} = schema do
    initial_node = Enum.find(schema.nodes,  fn n -> n.type == :initial end)

    if initial_node == nil do
      raise "Cannot initialise a workflow where the schema does not specify an initial node."
    end

    %Workflow{
      schema: schema,
      states: [
        %State{id: initial_node.id},
      ],
    }
  end
end
