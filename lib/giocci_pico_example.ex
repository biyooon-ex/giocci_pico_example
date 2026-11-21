defmodule GiocciPicoExample do
  @moduledoc """
  Documentation for `GiocciPicoExample`.
  """

  @compile {:no_warn_undefined, [:esp, :network]}

  @relay_name "giocci_relay"
  @client_name "giocci_pico_example"

  @doc """
  """
  def start do
    IO.puts("""
    =========================
    This is GiocciPicoExample
    =========================
    """)

    # Run these once to configure your Wi-Fi station.
    # :esp.nvs_put_binary(:atomvm, :sta_ssid, "SSID")
    # :esp.nvs_put_binary(:atomvm, :sta_psk, "Password")

    # Connect to Wi-Fi
    {:ok, ssid} = :esp.nvs_fetch_binary(:atomvm, :sta_ssid)
    {:ok, psk} = :esp.nvs_fetch_binary(:atomvm, :sta_psk)

    :ok = connect_wifi(ssid, psk)

    # Prepare ZenohexPico
    zenohd_connect_endpoint = "tcp/192.168.0.95:7447"
    {:ok, config} = ZenohexPico.Config.default()
    {:ok, config} = ZenohexPico.Config.insert(config, :connect, zenohd_connect_endpoint)

    # Start GiocciPico
    children = [
      {GiocciPico, zenohex_pico_config: config, client_name: @client_name, key_prefix: ""}
      # Add your other GenServers and supervisors
    ]

    {:ok, _pid} = Supervisor.start_link(children, strategy: :one_for_one)

    # Call each function below
    :ok = GiocciPico.register_client(@relay_name)

    :ok = GiocciPico.save_module(@relay_name, GiocciPicoExample.BasicCalc)

    5 = GiocciPico.exec_func(@relay_name, {GiocciPicoExample.BasicCalc, :add, [2, 3]})
    6 = GiocciPico.exec_func(@relay_name, {GiocciPicoExample.BasicCalc, :multiply, [2, 3]})
    8.0 = GiocciPico.exec_func(@relay_name, {GiocciPicoExample.BasicCalc, :power, [2, 3]})
    5 = GiocciPico.exec_func(@relay_name, {GiocciPicoExample.BasicCalc, :fib, [5]})

    :ok
  end

  defp connect_wifi(ssid, psk, pid \\ self()) do
    {:ok, _} =
      :network.start_link(
        sta: [
          ssid: ssid,
          psk: psk,
          connected: fn -> IO.puts("WiFi connected!") end,
          got_ip: fn _info -> send(pid, :got_ip) end,
          disconnected: fn -> IO.puts("WiFi disconnected") end
        ]
      )

    IO.puts("Waiting for WiFi...")

    receive do
      :got_ip -> :ok
    end
  end
end
