# GiocciPicoExample

The example code and its instruction for [Giocci Platform](https://github.com/biyooon-ex/giocci_platform).

GiocciPicoExample releases follow Giocci's version numbers; use the matching GiocciPlatform release for GiocciRelay and GiocciEngine.

This explanation assumes that the GiocciRelay and GiocciEngine environment with your Zenoh router described in [Giocci's Quick Start](https://github.com/biyooon-ex/giocci_platform#quick-start) has already been deployed.

## Using GiocciPico

This section explains how to use GiocciPico by walking through the following two files:

1. [`mix.exs`](./mix.exs)
2. [`lib/giocci_pico_example.ex`](./lib/giocci_pico_example.ex)

### Configuring `mix.exs`

The `mix.exs` file contains the configuration needed to use GiocciPico.

First, add `:giocci_pico` and the dependencies needed for AtomVM development,
[:exatomvm](https://github.com/atomvm/exatomvm) and `:atomvm`.

```elixir
  defp deps do
    [
      {:giocci_pico, "== 0.7.0-alpha.2"},
      {:exatomvm, github: "atomvm/exatomvm", runtime: false, override: true},
      {:atomvm, "~> 0.7.0-beta.0", runtime: false}
    ]
  end
```

Next, configure the AtomVM start module and a flashing alias in `project/0`.

```elixir
  def project do
    [
      # ...
      # AtomVM settings. For details, see https://github.com/atomvm/exatomvm.
      atomvm: [
        # The module whose start function AtomVM calls at boot.
        start: GiocciPicoExample
      ],
      aliases: [
        # An alias to simplify flashing.
        flash: [
          "atomvm.packbeam",
          "atomvm.esp32.flash --port /dev/ttyACM0 --baud 921600"
        ]
      ]
    ]
  end
```

> [!NOTE]
> Before flashing, follow the [GiocciPico setup instructions](https://github.com/biyooon-ex/giocci_platform/blob/main/apps/giocci_pico/README.md#Usage)
> to prepare an AtomVM build with zenoh-pico and place `avm_deps` in the project.
> Change `/dev/ttyACM0` to your device's serial port, then run `mix flash`
> to package and flash the sample to an ESP32.

Finally, add `cli/0` to set the default Mix target to `:avm_esp32`.
This normally removes the need to run `export MIX_TARGET=avm_esp32` for this project.

```elixir
  def cli do
    [default_target: :avm_esp32]
  end
```

### How `lib/giocci_pico_example.ex` works

This file defines the `start/0` function called when AtomVM boots.
The function performs the following steps:

1. Read the saved SSID and password and connect to Wi-Fi.
2. Configure the ZenohexPico connection endpoint.
3. Start GiocciPico as a child of a supervisor.
4. Register the client, save `GiocciPicoExample.BasicCalc`, and execute its functions.

Before running the sample, use the `:esp.nvs_put_binary/3` examples in the file
to save your Wi-Fi SSID and password on the device.
Also, change the Zenoh router endpoint and relay name to match your environment.
If you put your SSID or password in the source code, do not commit them.
