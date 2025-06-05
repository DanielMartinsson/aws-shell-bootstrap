# AWS Shell Bootstrap

> Fast-track your remote development environment with Zsh, Tmux, Neovim, and modern CLI tools.

This bootstrap script sets up a modern shell environment on a fresh Linux server — ideal for cloud-based development or repeatable provisioning.  
It installs and configures:

- **Zsh + Oh My Zsh**
- **Tmux** (with sensible defaults)
- **Neovim** (AppImage extracted, no FUSE required)
- **NvChad** (or LazyVim, optional)
- CLI tools: `fzf`, `ripgrep`, `bat`, `jq`, `htop`, `ncdu`

---

## 🚀 Quick Start

SSH into your fresh machine and run:

```bash
bash <(curl -sS https://raw.githubusercontent.com/DanielMartinsson/aws-shell-bootstrap/main/bootstrap.sh)
```

> ✅ Works best on CentOS 8.5 and other RHEL-based distros.

---

## 🛠 Options

| Flag           | Description                                      |
|----------------|--------------------------------------------------|
| `--reset-nvim` | Reinstall Neovim even if already installed       |

You can safely re-run the script — it will back up your existing configs.

---

## 🔄 Uninstall

To clean up everything installed by the bootstrap, run:

```bash
bash <(curl -sS https://raw.githubusercontent.com/DanielMartinsson/aws-shell-bootstrap/main/uninstall.sh)
```

You’ll be prompted before removing shared tools or reverting your shell.

---

## 🧠 Notes

- Neovim is installed from [neovim-releases](https://github.com/neovim/neovim-releases) and unpacked manually for compatibility with older glibc.
- Zsh is installed and set as your login shell (or prompts if `chsh` is unavailable).
- The script is modular and can be adapted to support LazyVim, LunarVim, or dotfile sync.

---

## 🧪 Tested On

- ✅ CentOS 8.5.2111


---

## 📂 Structure

```
bootstrap.sh     # Main setup script
uninstall.sh     # Clean-up script
```

---

## 📜 License

MIT — free to use, fork, and adapt.
