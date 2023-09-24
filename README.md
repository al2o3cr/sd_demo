# SdDemo

Demonstration project for connecting to an Elgato Stream Deck + from Elixir.

## Installation

The hard part to install will be `libvips` - see your local package manager for details.

After that, you'll need to do the usual `mix deps.get`

## Usage

* Connect a single Stream Deck + via USB.

* start up `iex` using `iex -S mix`

* start the demo with `SdDemo.ArcsSim.start_link([])`

The only option supported for `ArcsSim.start_link/1` is `poll_rate`, which specifies how many milliseconds to sleep before polling the Stream Deck + again.

## Details

The goal of this project is to test UI concepts for using a Stream Deck + to replace a Monome Arc.

Each of the four rings starts out "rotating" at a random speed.

Turning the corresponding knob will change that speed.

Clicking the corresponding knob will set the speed to zero.

![Demo video](docs/demo.MOV)

Each of the four "rings" is composed of 64 segments, each with 0-15 brightness.

## Future plans

* figure out something interesting to do with the buttons

* figure out something interesting to do with touches / swipes on the big LCD

* make `ArcsSim` quack identically to [`serialosc`](https://monome.org/docs/serialosc/) and try it out with an application that's expecting an Arc

* port the code to Lua and/or C and make it work on [norns](https://monome.org/docs/norns/)
