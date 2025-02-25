# このスクリプトは、WSL2 の Ubuntu 24.04 LTS に開発環境を構築する cloud-init の設定ファイルを生成するスクリプトです。
# ディストロ名を指定
param (
    [string]$Password = "P@ssword"  # デフォルト値を設定可能
)

$DistroName = "ubuntu2404-dev"

# パスワードを SHA-512 でハッシュ化
$HashedPassword = wsl -e openssl passwd -6 $Password

# 現在のディレクトリに '.cloud-init' ディレクトリを作成
$CloudInitDir = Join-Path -Path $PSScriptRoot -ChildPath ".cloud-init"
if (-not (Test-Path -Path $CloudInitDir)) {
    New-Item -Path $CloudInitDir -ItemType Directory
}

# cloud-init の設定ファイルを作成
$CloudInitFile = Join-Path -Path $CloudInitDir -ChildPath "$DistroName.user-data"
Write-Host "'$CloudInitFile' を作成しています..."
@"
#cloud-config
users:
- name: wsluser
  gecos: WSL User
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
  groups: sudo, docker
  lock_passwd: false
  passwd: $HashedPassword # 必要ならパスワードを変更
locale: ja_JP.UTF-8
timezone: Asia/Tokyo
package_update: true
package_upgrade: true

packages:
- curl
- git
- gh
- docker.io
- dotnet-sdk-8.0
- zip

runcmd:
# Docker の設定
- sudo usermod -aG docker wsluser
- sudo service docker start
# Oh My Posh のインストール
- sudo -u wsluser -i -- bash -c "mkdir ~/bin"
- sudo -u wsluser -i -- bash -c "export PATH=`$PATH:~/bin"
- sudo -u wsluser -i -- bash -c "curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin"
- sudo -u wsluser -i -- bash -c "oh-my-posh init bash --config ~/.cache/oh-my-posh/themes/1_shell.omp.json > ~/.oh-my-posh-init.sh"
- sudo mv -v /home/wsluser/.oh-my-posh-init.sh /etc/profile.d/oh-my-posh-init.sh
- echo "source /etc/profile.d/oh-my-posh-init.sh" | sudo tee -a /home/wsluser/.bashrc
- sudo apt update && sudo apt full-upgrade -y

write_files:
- path: /etc/wsl.conf
  append: true
  content: |
    [boot]
    systemd=true
    [user]
    default=wsluser
"@ | Set-Content -Path $CloudInitFile -Encoding UTF8

# コピー先フォルダのパスを設定
$DestDir = Join-Path -Path $env:UserProfile -ChildPath ".cloud-init"

# コピー先フォルダが存在しない場合は作成
if (-not (Test-Path -Path $DestDir)) {
    New-Item -Path $DestDir -ItemType Directory -Force
}

# コピー先のファイルパスを設定
$DestFile = Join-Path -Path $DestDir -ChildPath (Split-Path -Leaf $CloudInitFile)

# ファイルを上書きコピー
Copy-Item -Path $CloudInitFile -Destination $DestFile -Force

Write-Host "'$CloudInitFile' を '$DestFile' にコピーしました。"

# WSL に Ubuntu-24.04 を指定した名前でインストール
Write-Host "指定したディストロ名 '$DistroName' が既に存在するか確認します..."

# WSL のディストロ一覧を取得
$ExistingDistros = & wsl.exe --list --quiet

# ディストロが存在する場合は登録解除
if ($ExistingDistros -contains $DistroName) {
    Write-Host "'$DistroName' が既に存在します。登録を解除します..."
    & wsl.exe --unregister $DistroName
    Write-Host "'$DistroName' を登録解除しました。"
}

# WSL に Ubuntu-24.04 を指定した名前でインストール
Write-Host "WSL に '$DistroName' をインストールします..."
& wsl.exe --install -d Ubuntu-24.04 --name $DistroName --no-launch

# インストール後に初期起動
Write-Host "'$DistroName' を初期起動します..."
& wsl.exe -d $DistroName
Write-Host "'$DistroName' の初期起動が完了しました。"
