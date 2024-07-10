defmodule Basic.Pipeline do
  use Membrane.Pipeline


  @impl true
  def handle_init(_context, _options) do
    spec = [
      child(:bin1, %Basic.Bin{input_filename: "input.A.txt"})
      |> via_in(:first_input)
      |> child(:mixer, Basic.Elements.Mixer)
      |> child(:output, %Basic.Elements.Sink{location: "output.txt"}),

      child(:bin2, %Basic.Bin{input_filename: "input.B.txt"})
      |> via_in(:second_input)
      |> get_child(:mixer),

      get_child(:mixer)
      |> child(:output, %Basic.Elements.Sink{location: "output.txt"})
    ]

    {[spec: spec], %{}}
  end
end
