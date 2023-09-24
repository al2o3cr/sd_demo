defmodule SdDemo.DrawWedges do
  import :math

  def circle_point(r, {cx, cy}, th) do
    {cx + r * sin(th), cy + r * cos(th)}
  end

  def wedge_path(idx, r, c, n, dw) do
    dth = 2 * pi() / n

    th_start = dth * (-idx - dw / 2 - n / 2)
    {start_x, start_y} = circle_point(r, c, th_start)

    th_end = dth * (-idx + dw / 2 - n / 2)
    {end_x, end_y} = circle_point(r, c, th_end)

    "M#{start_x},#{start_y} A#{r},#{r} 0 0,0 #{end_x},#{end_y}"
  end

  def arc_svg(colors, r, {cx, cy} = c, dw) do
    n = 64
    intensity_steps = 15

    stroke_width = 2 * (cy - r)

    0..(n - 1)
    |> Enum.map(fn idx ->
      """
        <path fill="none" stroke="white" stroke-opacity="#{format_opacity(Map.get(colors, idx, 0) / intensity_steps)}" stroke-width="#{stroke_width}" d="#{wedge_path(idx, r, c, n, dw)}"/>
      """
    end)
    |> Enum.join()
    |> String.trim()
    |> then(fn els ->
      """
      <svg height="#{2 * cy}" width="#{2 * cx}">
        #{els}
      </svg>
      """
    end)
  end

  defp format_opacity(v), do: to_string(v)

  # svg = SdDemo.DrawWedges.wedges_svg(%{0 => "blue", 2 => "yellow", 32 => "green"}, 300, {500, 500}, 64, 0.8)
  # {:ok, {img, _flags}} = Vix.Vips.Operation.svgload_buffer(svg)
  # f = File.stream!("output.jpg")
  # Image.write(img, f, suffix: ".jpg", quality: 100)
  def wedges_svg(colors, r, {cx, cy} = c, n, dw) do
    0..(n - 1)
    |> Enum.map(fn idx ->
      """
        <path fill="none" stroke="#{Map.get(colors, idx, "red")}" stroke-width="30" d="#{wedge_path(idx, r, c, n, dw)}"/>
      """
    end)
    |> Enum.join()
    |> String.trim()
    |> then(fn els ->
      """
      <svg height="#{2 * cy}" width="#{2 * cx}">
        <circle cx="#{cx}" cy="#{cy}" r="#{r}" fill="none" stroke="black" stroke-width="1"/>
        <line x1="#{cx}" y1="#{cy}" x2="#{cx}" y2="#{cy - r}" stroke="purple"/>
        <line x1="#{cx}" y1="#{cy}" x2="#{cx - r}" y2="#{cy}" stroke="orange"/>
        <line x1="#{cx}" y1="#{cy}" x2="#{cx}" y2="#{cy + r}" stroke="orange"/>
        <line x1="#{cx}" y1="#{cy}" x2="#{cx + r}" y2="#{cy}" stroke="orange"/>
        #{els}
      </svg>
      """
    end)
  end
end
