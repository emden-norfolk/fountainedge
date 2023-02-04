defmodule Fountainedge.Graph.Dot do
  use GenServer
  require Logger

  def start_link(args \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(args \\ []) do
    command = "dot -Tdot #{args[:filename]}.dot"
    port = Port.open({:spawn, command}, [:binary, :exit_status])

    {:ok, %{
      port: port,
      gvpr_server: args[:gvpr_server],
      latest_output: nil,
      exit_status: nil,
    }}
  end

  def handle_info({_port, {:data, line}}, state) do
    GenServer.call(state.gvpr_server, {:send, line})
    {:noreply, %{state | latest_output: line}}
  end

  def handle_info({_port, {:exit_status, status}}, state) do

    IO.inspect "Stopping dot."

    {:stop, :normal, %{state | exit_status: status}}
  end

  def handle_info(_msg, state), do: {:noreply, state}
end
