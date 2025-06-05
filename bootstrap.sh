#!/bin/bash
set -euo pipefail

echo "==> Bootstrapping remote shell environment... (version: 0.1.0)"

############################
# Configurable variables
############################

USE_LAZYVIM=false  # Set to true to use LazyVim instead of NvChad
RESET_NVIM=false   # Set with --reset-nvim flag

############################
# Helpers
############################

log() {
  echo -e "\033[1;32m[+]\033[0m $1"
}

err() {
  echo -e "\033[1;31m[!]\033[0m $1" >&2
}

check_flag() {
  for arg in "$@"; do
    if [ "$arg" == "--reset-nvim" ]; then
      RESET_NVIM=true
    fi
  done
}

############################
# Environment setup
############################

detect_package_manager() {
  if command -v apt &>/dev/null; then
    PKG=apt
    sudo apt update -y
    sudo apt install -y curl git bc
  elif command -v dnf &>/dev/null; then
    PKG=dnf
    sudo dnf install -y epel-release
    sudo dnf install -y curl git bc
  elif command -v yum &>/dev/null; then
    PKG=yum
    sudo yum install -y epel-release
    sudo yum install -y curl git bc
  else
    err "Unsupported package manager. Exiting."
    exit 1
  fi
}

############################
# Zsh + Oh My Zsh
############################

setup_zsh() {
  if ! command -v zsh &>/dev/null; then
    log "Installing Zsh..."
    sudo "$PKG" install -y zsh
  fi

  export RUNZSH=no CHSH=no KEEP_ZSHRC=yes

  if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  if [ "$SHELL" != "$(which zsh)" ]; then
    if command -v chsh &>/dev/null; then
      log "Changing default shell to Zsh..."
      chsh -s "$(which zsh)"
    else
      log "chsh not found; run this manually:"
      echo "  sudo usermod -s $(which zsh) $USER"
    fi
  fi

  ZSHRC="$HOME/.zshrc"
  if ! grep -q "oh-my-zsh.sh" "$ZSHRC" 2>/dev/null; then
    cat <<EOF >>"$ZSHRC"

# Added by bootstrap script
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source \$ZSH/oh-my-zsh.sh
EOF
  fi
}

############################
# Tmux
############################

setup_tmux() {
  if ! command -v tmux &>/dev/null; then
    log "Installing tmux..."
    sudo "$PKG" install -y tmux
  fi

  TMUX_CONF="$HOME/.tmux.conf"
  if [ ! -f "$TMUX_CONF" ]; then
    log "Creating .tmux.conf..."
    cat <<EOF >"$TMUX_CONF"
set -g mouse on
setw -g mode-keys vi
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"
set -g history-limit 10000
bind -n C-h select-pane -L
bind -n C-j select-pane -D
bind -n C-k select-pane -U
bind -n C-l select-pane -R
EOF
  fi
}

############################
# CLI Tools
############################

install_cli_tools() {
  TOOLS=(fzf ripgrep bat jq htop ncdu)
  for tool in "${TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      log "Installing $tool..."
      sudo "$PKG" install -y "$tool" || log "Failed to install $tool"
    fi
  done
}

############################
# Neovim
############################

install_neovim() {
  log "Installing Neovim AppImage without FUSE..."

  curl -LO https://github.com/neovim/neovim-releases/releases/download/v0.11.1/nvim-linux-x86_64.appimage

  chmod u+x nvim-linux-x86_64.appimage

  ./nvim-linux-x86_64.appimage --appimage-extract

  # Move extracted Neovim to a fixed path
  sudo mv squashfs-root /opt/nvim
  sudo ln -sf /opt/nvim/AppRun /usr/local/bin/nvim

  rm -f nvim-linux-x86_64.appimage

  echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
  echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
}





is_old_nvim() {
  if ! command -v nvim &>/dev/null; then return 0; fi
  ver=$(nvim --version | head -n1 | grep -oP '\d+\.\d+')
  echo "$ver < 0.10" | bc -l | grep -q 1
}

############################
# Neovim Config
############################

setup_nvim_config() {
  NVIM_CONFIG="$HOME/.config/nvim"
  [ -d "$NVIM_CONFIG" ] && mv "$NVIM_CONFIG" "$NVIM_CONFIG.backup.$(date +%s)"

  if $USE_LAZYVIM; then
    log "Installing LazyVim..."
    git clone https://github.com/LazyVim/starter "$NVIM_CONFIG" --depth 1
  else
    log "Installing NvChad..."
    git clone https://github.com/NvChad/starter "$NVIM_CONFIG" --depth 1
  fi

  rm -rf "$NVIM_CONFIG/.git"

  log "Syncing Neovim plugins (headless)..."
  nvim --headless +"autocmd User LazyDone ++once lua require('mason').setup(); require('mason-tool-installer').run_on_start()" +qa || true
}

############################
# Main
############################

main() {

  check_flag "$@"
  detect_package_manager
  setup_zsh
  setup_tmux
  install_cli_tools

  if $RESET_NVIM || is_old_nvim; then
    install_neovim
  else
    log "Neovim already installed and up to date."
  fi

  setup_nvim_config

  log "==> DONE! Open a new shell or run 'zsh' to start."
}

main "$@"
