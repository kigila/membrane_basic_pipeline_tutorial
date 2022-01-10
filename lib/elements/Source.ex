defmodule Basic.Elements.Source do
  @moduledoc """
  A module that provides a source element allowing to read a packetized data from the input text file.
  """

  use Membrane.Source
  alias Membrane.Buffer

  def_options(
    location: [type: :string, description: "Path to the input file with packetized data"]
  )

  def_output_pad(:output, caps: {Basic.Formats.Packet, type: :custom_packets}, mode: :pull)

  @impl true
  def handle_init(options) do
    {:ok,
     %{
       location: options.location,
       content: nil
     }}
  end

  @impl true
  def handle_stopped_to_prepared(_ctx, state) do
    raw_file_binary = File.read!(state.location)
    content = String.split(raw_file_binary, "\n")
    state = %{state | content: content}
    {{:ok, [caps: {:output, %Basic.Formats.Packet{type: :custom_packets}}]}, state}
  end

  @impl true
  def handle_prepared_to_stopped(_ctx, state) do
    state = %{state | content: nil}
    {:ok, state}
  end

  @impl true
  def handle_demand(:output, 0, :buffers, _ctx, state) do
    {:ok, state}
  end

  @impl true
  def handle_demand(:output, size, :buffers, _ctx, state) do
    if state.content == [] do
      {{:ok, end_of_stream: :output}, state}
    else
      [chosen | rest] = state.content
      state = %{state | content: rest}
      action = [buffer: {:output, %Buffer{payload: chosen}}]
      action = if size > 1, do: action ++ [redemand: :output], else: action
      {{:ok, action}, state}
    end
  end
end
