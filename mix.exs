defmodule GiocciPicoExample.MixProject do
  use Mix.Project

  def project do
    [
      app: :giocci_pico_example,
      version: "0.7.0-alpha.3",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      atomvm: [
        start: GiocciPicoExample
      ],
      aliases: [
        flash: [
          "atomvm.packbeam",
          "atomvm.esp32.flash --port /dev/ttyACM0 --baud 921600"
        ]
      ]
    ]
  end

  def cli do
    [default_target: :avm_esp32]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:giocci_pico, "== 0.7.0-alpha.3"},
      {:exatomvm, github: "atomvm/exatomvm", runtime: false, override: true},
      {:atomvm, "~> 0.7.0-beta.0", runtime: false}
    ]
  end
end
