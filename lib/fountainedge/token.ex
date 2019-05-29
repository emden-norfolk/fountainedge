defmodule Fountainedge.Token do
  @moduledoc """
  Documentation for Fountainedge.Token.
  """

  @enforce_keys [:id, :token]

  defstruct id: nil, token: nil
end
