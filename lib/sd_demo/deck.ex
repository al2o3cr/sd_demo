defmodule SdDemo.Deck do
  alias SdDemo.DrawWedges

  def get_device do
    [d] = Streamdex.devices()

    Streamdex.start(d)
  end

  def set_key_images(d) do
    image = "priv/images/sample.png" |> File.read!() |> d.module.to_key_image()

    d.module.set_key_image(d, 0, image)
    d.module.set_key_image(d, 1, image)
    d.module.set_key_image(d, 2, image)
    d.module.set_key_image(d, 3, image)
    d.module.set_key_image(d, 4, image)
    d.module.set_key_image(d, 5, image)
    d.module.set_key_image(d, 6, image)
    d.module.set_key_image(d, 7, image)
  end

  def draw_key_image(d, n, v) do
    img = Image.Text.text!(to_string(v), font_size: 0, autofit: true, width: 120, height: 120)

    bin = Image.write!(img, :memory, suffix: ".jpg", quality: 100)

    d.module.set_key_image(d, n, bin)
  end

  def clear_lcd(d) do
    img = Image.new!(800, 100)
    bin = Image.write!(img, :memory, suffix: ".jpg", quality: 100)
    d.module.set_lcd_image(d, 0, 0, 800, 100, bin)
  end

  def draw_lcd_text(d, v) do
    img = Image.Text.text!(to_string(v), font_size: 0, autofit: true, width: 800, height: 100)

    IO.inspect(Image.shape(img))
    bin = Image.write!(img, :memory, suffix: ".jpg", quality: 100)

    d.module.set_lcd_image(d, 0, 0, 800, 100, bin)
  end

  def draw_arc(d, start_x, segments) do
    svg = DrawWedges.arc_svg(segments, 30, {50, 50}, 0.9)
    {:ok, {img, _flags}} = Vix.Vips.Operation.svgload_buffer(svg)
    bin = Image.write!(img, :memory, suffix: ".jpg", quality: 100)
    d.module.set_lcd_image(d, start_x, 0, 100, 100, bin)
  end
end
