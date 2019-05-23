defmodule Fountainedge.Node do
  @moduledoc """
  Documentation for Fountainedge.Node.
  """

  alias __MODULE__

  def standard, do: 0
  def initial, do: 1
  def final, do: 2
  def fork, do: 3
  def join, do: 4

  defstruct id: nil, type: 0
end
