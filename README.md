# wsl-cloud-init
 📝WSL2 上の Ubuntu 24.04 LTS を自動セットアップするスクリプトです。

このリポジトリには、WSL2 上で Ubuntu 24.04 LTS をセットアップするための PowerShell スクリプト `setup-wsl-ubuntu2404-dev.ps1` が含まれています。
このスクリプトは、cloud-init を利用して開発環境を自動構築します。

## 特徴
- WSL2 上の Ubuntu 24.04 LTS ディストロを自動インストール
- cloud-init によるプロビジョニングを利用して以下を設定:
  - ユーザーの作成とパスワード設定
  - ロケールとタイムゾーンの設定
  - 必要なパッケージのインストール (例: `curl`, `git`, `docker.io` など)
  - Docker のセットアップ
  - Oh My Posh のインストールと設定
  - WSL の systemd 有効化

## 注意事項
- スクリプト実行前に、同じ名前のディストロが既に存在する場合は自動的に登録解除 (`wsl --unregister`) が行われます。
- 登録解除されるディストロのデータは削除されるため、必要に応じて事前にバックアップを取ってください。

## 必要な環境
以下は、WSL のバージョン情報を確認するコマンドの出力例です。

```ps1
PS> wsl --version
WSL バージョン: 2.4.11.0
カーネル バージョン: 5.15.167.4-1
WSLg バージョン: 1.0.65
MSRDC バージョン: 1.2.5716
Direct3D バージョン: 1.611.1-81528511
DXCore バージョン: 10.0.26100.1-240331-1435.ge-release
Windows バージョン: 10.0.26100.3194
```

## 使い方

### 1. スクリプトの実行
```ps1
.\setup-wsl-ubuntu2404-dev.ps1 -Password "YourPasswordHere"
```

### 2. 初回起動
スクリプト実行後、自動的に指定したディストロ名（例: ubuntu2404-dev）で WSL の初回起動が行われます。

### 3. cloud-init によるプロビジョニングの確認
セットアップ後、以下のコマンドで cloud-init の状態を確認できます。
```bash
#!/bin/bash
whoami
sudo cloud-init status --wait --format json
sudo cloud-init query userdata
sudo cat /var/log/cloud-init-output.log
```

### スクリプトの動作概要
1. WSL のディストロ名として ubuntu2404-dev を設定。
2. cloud-init 用の設定ファイルを生成し、必要なパッケージや設定を記述。
3. WSL に Ubuntu 24.04 をインストール。
   - 既存のディストロ名が存在する場合は登録解除を実行。
4. インストール完了後に初回起動を実行。
5. cloud-init によるプロビジョニングを実行。

## 参考
* [Using WSL with cloud\-init \- cloud\-init 25\.1 documentation](https://docs.cloud-init.io/en/latest/howto/launch_wsl.html#launch-wsl)
* [WSL \- cloud\-init 25\.1 documentation](https://docs.cloud-init.io/en/latest/reference/datasources/wsl.html#wsl-user-data-configuration)
