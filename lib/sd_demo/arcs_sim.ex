defmodule SdDemo.ArcsSim do
  use GenServer

  alias SdDemo.Deck

  defmodule Ring do
    defstruct [:start_x, :segments, :offset, :velocity]

    alias SdDemo.Deck

    def new(start_x, segments \\ %{0 => 15}) do
      %__MODULE__{start_x: start_x, segments: segments, offset: 0, velocity: 4 * :rand.uniform()}
    end

    def handle_turn(r, :left, amount) do
      %{r | velocity: r.velocity - 0.1 * amount}
    end

    def handle_turn(r, :right, amount) do
      %{r | velocity: r.velocity + 0.1 * amount}
    end

    def handle_turn(r, :none, _), do: r

    def handle_button(r, :down) do
      %{r | velocity: 0}
    end

    def handle_button(r, :up) do
      r
    end

    def draw(r, d) do
      segments = rotate(r.segments, r.offset)
      Deck.draw_arc(d, r.start_x, Map.put(segments, 0, 4))
    end

    def update(r) do
      %{r | offset: r.offset + r.velocity}
    end

    defp rotate(segments, offset) do
      Map.new(segments, fn {k, v} -> {Integer.mod(k + floor(offset), 64), v} end)
    end
  end

  defstruct [:device, :poll_rate, :rings]

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, options)
  end

  def init(options) do
    device = Deck.get_device()

    poll_rate = Keyword.get(options, :poll_rate, 10)

    rings = %{
      0 => Ring.new(50),
      1 => Ring.new(250),
      2 => Ring.new(450),
      3 => Ring.new(650)
    }

    Deck.clear_lcd(device)

    state = %__MODULE__{device: device, poll_rate: poll_rate, rings: rings}

    poll(state)
    {:ok, state}
  end

  def handle_info(:poll, state) do
    state =
      case state.device.module.poll(state.device) do
        nil -> state
        result -> handle_input(result, state)
      end

    state = update(state)
    draw(state)
    poll(state)
    {:noreply, state}
  end

  def draw(state) do
    Enum.each(state.rings, fn {_, r} -> Ring.draw(r, state.device) end)
  end

  def update(state) do
    %{state | rings: Map.new(state.rings, fn {i, r} -> {i, Ring.update(r)} end)}
  end

  def handle_input(%{event: :turn, part: :knobs, states: knobs}, state) do
    new_rings =
      knobs
      |> Enum.with_index()
      |> Map.new(fn {{dir, amount}, i} ->
        {i, Ring.handle_turn(state.rings[i], dir, amount)}
      end)

    %{state | rings: new_rings}
  end

  def handle_input(%{event: :button, part: :knobs, states: knobs}, state) do
    new_rings =
      knobs
      |> Enum.with_index()
      |> Map.new(fn {b, i} ->
        {i, Ring.handle_button(state.rings[i], b)}
      end)

    %{state | rings: new_rings}
  end

  def handle_input(input, state) do
    IO.inspect(input)
    state
  end

  defp poll(state) do
    Process.send_after(self(), :poll, state.poll_rate)
  end
end
