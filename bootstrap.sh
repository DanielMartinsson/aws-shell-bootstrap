#!/bin/bash

# aws-shell-bootstrap v0.1.0
# This script installs ghosty, tmux, neovim, and essential CLI tools on Debian/Ubuntu or RHEL/CentOS.

set -euo pipefail
IFS=$'\n\t'

### Utility functions

log() { echo -e "\033[1;32m[+]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*" >&2; }
error() {
  echo -e "\033[1;31m[✗]\033[0m $*" >&2
  exit 1
}

### Detect OS

detect_os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
    ubuntu | debian) echo "debian" ;;
    centos | rhel | rocky | almalinux) echo "redhat" ;;
    *) error "Unsupported distro: $ID" ;;
    esac
  else
    error "Cannot detect OS"
  fi
}

### Install packages

install_pkgs() {
  local os=$1
  log "Installing base packages for $os..."

  if [ "$os" = "debian" ]; then
    sudo apt-get update -qq
    sudo apt-get install -y git curl tmux neovim fzf ripgrep bat jq htop ncdu
  elif [ "$os" = "redhat" ]; then
    sudo yum install -y epel-release || true
    sudo yum install -y git curl tmux jq htop ncdu gcc make unzip

    # Neovim via copr
    if ! command -v nvim &>/dev/null; then
      log "Installing Neovim from copr..."
      sudo yum install -y 'dnf-command(copr)' || true
      sudo dnf copr enable agriffis/neovim -y || true
      sudo yum install -y neovim || warn "Neovim install failed"
    fi

    # Fzf
    if ! command -v fzf &>/dev/null; then
      log "Installing fzf..."
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      yes | ~/.fzf/install --all
    fi

    # ripgrep
    if ! command -v rg &>/dev/null; then
      install_from_github "BurntSushi/ripgrep" "rg"
    fi

    # bat
    if ! command -v bat &>/dev/null; then
      install_from_github "sharkdp/bat" "bat"
    fi

    # btop (optional)
    if ! command -v btop &>/dev/null; then
      install_from_github "aristocratos/btop" "btop"
    fi
  fi
}

install_from_github() {
  local repo=$1
  local bin=$2
  local tmp_dir
  tmp_dir=$(mktemp -d)

  arch=$(uname -m)
  [ "$arch" = "x86_64" ] && arch="amd64"

  url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" |
    grep browser_download_url |
    grep -E 'linux.*(tar.gz|rpm)' |
    grep "$arch" |
    cut -d '"' -f 4 |
    head -n1)

  if [ -z "$url" ]; then
    warn "No binary found for $bin"
    return
  fi

  cd "$tmp_dir"
  curl -LO "$url"

  if [[ "$url" == *.rpm ]]; then
    sudo rpm -i "$(basename "$url")"
  elif [[ "$url" == *.tar.gz ]]; then
    tar -xf "$(basename "$url")"
    binpath=$(find . -type f -name "$bin" | head -n1)
    [ -x "$binpath" ] && sudo cp "$binpath" /usr/local/bin/
  fi

  rm -rf "$tmp_dir"
}

### Shell config

setup_shell() {
  log "Setting shell to ghosty if available (placeholder)"
  # Replace this with actual ghosty setup once available
}

### Tmux config

setup_tmux() {
  log "Creating minimal .tmux.conf"
  cat <<EOF >~/.tmux.conf
set -g mouse on
setw -g mode-keys vi
set-option -g history-limit 10000
EOF
}

### Neovim config

setup_neovim() {
  log "Creating minimal init.vim"
  mkdir -p ~/.config/nvim
  cat <<EOF >~/.config/nvim/init.vim
set number
set relativenumber
set tabstop=4 shiftwidth=4 expandtab
syntax on
set mouse=a
set clipboard=unnamedplus
EOF
}

### Main

main() {
  os=$(detect_os)
  install_pkgs "$os"
  setup_shell
  setup_tmux
  setup_neovim

  log "All done! Start tmux with: tmux"
}

main "$@"
