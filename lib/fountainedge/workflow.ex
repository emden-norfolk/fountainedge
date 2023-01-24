defmodule Fountainedge.Workflow do
  @moduledoc """
  Models a workflow (stateful.)

  The workflow is based on a `Fountainedge.Schema`

  Current nodes of the flowchart are tracked in a list of `Fountainedge.State`.
  """

  alias Fountainedge.{Workflow, Schema, State}

  @enforce_keys [:schema, :states]

  defstruct schema: %Schema{nodes: [], edges: []},
    states: []

  @typedoc """
  Workflow structure.
  * `:schema` - The `Fountainedge.Schema`.
  * `:states` - Workflow status.
  """

  @type t :: %__MODULE__{
    schema: Fountainedge.Schema.t(),
    states: list(Fountainedge.State.t()) | []
  }

  @doc """
  Initialises a workflow.

  Will set the current state to the initial node specified in the schema.
  """
  @spec initialize(Fountainedge.Schema.t()) :: Fountainedge.Workflow.t()
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
