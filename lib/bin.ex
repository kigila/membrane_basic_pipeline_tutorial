defmodule Basic.Bin do
  use Membrane.Bin


  def_output_pad :output, accepted_format: %Basic.Formats.Frame{encoding: :utf8}

  def_options input_filename: [
    type: :string,
    description: "Input file for conversation"
  ]

  @impl true
  def handle_init(_ctx, opts) do
    spec = [
      child(:input, %Basic.Elements.Source{location: opts.input_filename})
      |> child(:ordering_buffer, Basic.Elements.OrderingBuffer)
      |> child(:depayloader, %Basic.Elements.Depayloader{packets_per_frame: 4})
      |> bin_output(:output)
    ]

    {[spec: spec], %{}}
  end
end
