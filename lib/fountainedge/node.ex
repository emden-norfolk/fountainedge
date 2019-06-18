defmodule Fountainedge.Node do
  @moduledoc """
  Documentation for Fountainedge.Node.
  """

  @enforce_keys [:id]

  defstruct id: nil, type: :normal, join: nil, label: nil

  def find(nodes, id) do
    Enum.find(nodes, fn node -> node.id == id end)
  end
end
