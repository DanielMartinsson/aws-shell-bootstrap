#!/bin/bash
set -euo pipefail

log() {
  echo -e "\033[1;33m[-]\033[0m $1"
}

confirm() {
  read -rp "$1 [y/N]: " yn
  [[ "$yn" == "y" || "$yn" == "Y" ]]
}

remove_nvim() {
  log "Removing Neovim AppImage..."
  sudo rm -rf /opt/nvim-linux-x86_64
  sed -i '/nvim-linux-x86_64\/bin/d' ~/.zshrc || true
  sed -i '/nvim-linux-x86_64\/bin/d' ~/.bashrc || true
}

remove_nvim_config() {
  log "Removing Neovim configuration..."
  [ -d "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$HOME/.config/nvim.removed.$(date +%s)"
  [ -d "$HOME/.local/share/nvim" ] && mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.removed.$(date +%s)"
  [ -d "$HOME/.local/state/nvim" ] && mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.removed.$(date +%s)"
  [ -d "$HOME/.cache/nvim" ] && mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.removed.$(date +%s)"
}

remove_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Removing Oh My Zsh..."
    rm -rf "$HOME/.oh-my-zsh"
  fi

  sed -i '/^# Added by bootstrap script/,+4d' ~/.zshrc || true
}

remove_tmux() {
  if [ -f "$HOME/.tmux.conf" ]; then
    log "Removing .tmux.conf..."
    mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.removed.$(date +%s)"
  fi
}

remove_tools() {
  TOOLS=(fzf ripgrep bat jq htop ncdu tmux zsh)
  for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null && confirm "Remove $tool?"; then
      if command -v apt &>/dev/null; then
        sudo apt remove -y "$tool"
      elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
        sudo dnf remove -y "$tool" || sudo yum remove -y "$tool"
      fi
    fi
  done
}

restore_shell() {
  if [ "$SHELL" != "/bin/bash" ] && confirm "Revert default shell to bash?"; then
    chsh -s /bin/bash
    log "Shell will revert to bash next login."
  fi
}

main() {
  log "Starting cleanup..."
  remove_nvim
  remove_nvim_config
  remove_oh_my_zsh
  remove_tmux
  restore_shell
  remove_tools
  log "Done. Environment cleaned up."
}

main
