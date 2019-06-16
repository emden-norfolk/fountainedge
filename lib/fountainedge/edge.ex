defmodule Fountainedge.Edge do
  @moduledoc """
  Documentation for Fountainedge.Edge.
  """

  alias __MODULE__

  @enforce_keys [:id, :next]

  defstruct id: nil, next: nil

  def find(edges, %Edge{} = edge) do
    Enum.find(edges, fn e -> e == edge end)
  end

  def find(edges, id) do
    Enum.find(edges, fn edge -> edge.id == id end)
  end
end
