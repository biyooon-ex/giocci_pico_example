# GiocciPicoExample

The example code and its instruction for [Giocci Platform](https://github.com/biyooon-ex/giocci_platform).

GiocciPicoExample releases follow Giocci's version numbers; use the matching GiocciPlatform release for GiocciRelay and GiocciEngine.

This explanation assumes that the GiocciRelay and GiocciEngine environment with your Zenoh router described in [Giocci's Quick Start](https://github.com/biyooon-ex/giocci_platform#quick-start) has already been deployed.

## GiocciPico の使い方

GiocciPico の使い方を、次の2つのファイルに沿って説明します。

1. [`mix.exs`](./mix.exs)
2. [`lib/giocci_pico_example.ex`](./lib/giocci_pico_example.ex)

### `mix.exs` の設定

GiocciPico を使うための `mix.exs` の設定を説明します。

まず、依存関係に `:giocci_pico` と、AtomVM 向けの開発に必要な
[:exatomvm](https://github.com/atomvm/exatomvm) および `:atomvm` を追加します。

```elixir
  defp deps do
    [
      {:giocci_pico, "== 0.7.0-alpha.2"},
      {:exatomvm, github: "atomvm/exatomvm", runtime: false, override: true},
      {:atomvm, "~> 0.7.0-beta.0", runtime: false}
    ]
  end
```

次に、`project/0` に AtomVM の起動モジュールと書き込み用のエイリアスを設定します。

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
> 書き込みの前に、[GiocciPico のセットアップ手順](https://github.com/biyooon-ex/giocci_platform/blob/main/apps/giocci_pico/README.md#セットアップ)に従って、
> zenoh-pico を組み込んだ AtomVM の準備と `avm_deps` の配置を行ってください。
> このサンプルは、`/dev/ttyACM0` を使用するデバイスのシリアルポートに合わせて変更したうえで、
> `mix flash` でパックして ESP32 に書き込めます。

さらに、`cli/0` を追加して、デフォルトの Mix ターゲットを `:avm_esp32` に設定します。
これにより、このプロジェクトでは通常、`export MIX_TARGET=avm_esp32` を実行する必要がありません。

```elixir
  def cli do
    [default_target: :avm_esp32]
  end
```

### `lib/giocci_pico_example.ex` の処理

このファイルには、AtomVM の起動時に呼び出される `start/0` 関数を定義しています。
`start/0` では、次の処理を行います。

1. 保存済みの SSID とパスワードを読み込み、Wi-Fi に接続する
2. ZenohexPico の接続先を設定する
3. GiocciPico をスーパーバイザーの子プロセスとして起動する
4. クライアントを登録し、`GiocciPicoExample.BasicCalc` を保存して、その関数を実行する

実行前に、ファイル内の `:esp.nvs_put_binary/3` の例を使って、
使用する Wi-Fi の SSID とパスワードをデバイスに保存してください。
また、Zenoh ルーターの接続先とリレー名を利用環境に合わせて変更してください。
SSID やパスワードをソースコードに記載した場合は、コミットしないようにしてください。

