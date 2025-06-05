#!/bin/bash

# Function to install the latest Neovim via AppImage
install_neovim() {
  echo "Installing latest Neovim via AppImage..." &>/dev/null
  curl -LJO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage &>/dev/null
  chmod u+x nvim.appimage &>/dev/null
  sudo mv nvim.appimage /usr/local/bin/nvim &>/dev/null
}

# Function to install NvChad
install_nvchad() {
  NVIM_CONFIG="$HOME/.config/nvim"
  if [ -d "$NVIM_CONFIG" ]; then
    echo "Backing up existing Neovim config..." &>/dev/null
    mv "$NVIM_CONFIG" "$NVIM_CONFIG.backup.$(date +%s)" &>/dev/null
  fi

  echo "Installing NvChad starter..." &>/dev/null
  git clone https://github.com/NvChad/starter "$NVIM_CONFIG" --depth 1 &>/dev/null

  # Remove .git folder to detach from the template repo
  rm -rf "$NVIM_CONFIG/.git" &>/dev/null

  # Wait for Lazy.nvim to finish syncing, then install Mason packages
  echo "Syncing plugins and installing Mason packages..." &>/dev/null
  nvim --headless +"autocmd User LazyDone ++once lua require('mason').setup(); require('mason-tool-installer').run_on_start()" +qa &>/dev/null
}

echo "Setup complete! Open a new shell or type 'zsh' to get started." &>/dev/null

set -e

echo "==> Bootstrapping remote shell environment... (version: 0.0.4)"

# Detect package manager
if command -v apt &>/dev/null; then
  PKG=apt
  sudo apt update -y
  sudo apt install -y curl git
elif command -v dnf &>/dev/null; then
  PKG=dnf
  sudo dnf install -y curl git
elif command -v yum &>/dev/null; then
  PKG=yum
  sudo yum install -y curl git
else
  echo "Unsupported package manager. Exiting."
  exit 1
fi

# Install Zsh and Oh My Zsh
if ! command -v zsh &>/dev/null; then
  echo "Installing zsh..."
  sudo $PKG install -y zsh
fi

export RUNZSH=no
export CHSH=no
export KEEP_ZSHRC=yes
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ "$SHELL" != "$(which zsh)" ]; then
  if command -v chsh &>/dev/null; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
  else
    echo "chsh not found. You can manually change the default shell with:"
    echo "  sudo usermod -s $(which zsh) $USER"
  fi
fi

ZSHRC="$HOME/.zshrc"
if ! grep -q "oh-my-zsh.sh" "$ZSHRC" 2>/dev/null; then
  cat <<EOF >>"$ZSHRC"

# Added by bootstrap script
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source \$ZSH/oh-my-zsh.sh
EOF
fi

# Install CLI tools
CLI_TOOLS=(tmux fzf ripgrep bat jq htop ncdu)
for tool in "${CLI_TOOLS[@]}"; do
  if ! command -v $tool &>/dev/null; then
    echo "Installing $tool..."
    sudo $PKG install -y $tool || echo "Failed to install $tool"
  fi
done

# Install Tmux config (minimal)
TMUX_CONF="$HOME/.tmux.conf"
if [ ! -f "$TMUX_CONF" ]; then
  echo "Setting up .tmux.conf..."
  cat <<EOF >"$TMUX_CONF"
set -g mouse on
setw -g mode-keys vi
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"
EOF
fi

echo "Shell, tmux and cli tools installed. Proceeding with Neovim"

# Check for --reset-nvim flag
RESET_NVIM=false
for arg in "$@"; do
  if [ "$arg" == "--reset-nvim" ]; then
    RESET_NVIM=true
    break
  fi
done

if $RESET_NVIM; then
  echo "Reset flag detected. Reinstalling Neovim..." &>/dev/null
  install_neovim
else
  if ! command -v nvim &>/dev/null || [[ "$(nvim --version | head -n1 | grep -o '[0-9]\+\.[0-9]\+')" < "0.10" ]]; then
    install_neovim
  else
    echo "Neovim is already installed and up to date." &>/dev/null
  fi
fi

install_nvchad

echo "==> Done! Open a new shell or type 'zsh' to get started."
