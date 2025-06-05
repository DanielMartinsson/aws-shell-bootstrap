# AWS Shell Bootstrap

A minimal shell bootstrap script to quickly set up your preferred command-line environment on remote Linux servers. Designed for developers and power users who often connect to ephemeral or freshly provisioned EC2 instances or other remote machines.

This script installs:
- ✅ `tmux` (terminal multiplexer)
- ✅ `neovim` (modern Vim alternative)
- ✅ `fzf`, `ripgrep`, `bat`, `jq`, `htop`, `ncdu` (CLI tools for productivity)
- ✅ Sensible defaults for `.tmux.conf` and `init.vim`
- ✅ Works on **Ubuntu/Debian** and **CentOS/RHEL** systems

> ⚠️ Currently a placeholder for Ghosty shell — to be integrated when installable via script.

---

## 🔧 How to Use

### One-liner install (recommended):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/DanielMartinsson/aws-shell-bootstrap/main/bootstrap.sh)
```

This will:
1. Detect your distro (Ubuntu, Debian, CentOS, RHEL, etc.)
2. Install packages via `apt` or `yum`/`dnf`
3. Configure Neovim and Tmux with sensible defaults
4. Add useful CLI tools

---

## 🧠 Typical Workflow (From Your Local Machine)

1. **Connect to the remote instance via SSH**

```bash
ssh ec2-user@your-server-ip
```

2. **Run the bootstrap script**

Once logged into the remote server:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/DanielMartinsson/aws-shell-bootstrap/main/bootstrap.sh)
```

3. **Start working immediately**

```bash
tmux        # start your multiplexer
nvim file   # edit config or logs
fzf         # fuzzy-find files
rg error    # grep logs fast
bat file    # pretty cat
```

---

## 📂 Installed Tools

| Tool     | Description                                |
|----------|--------------------------------------------|
| `tmux`   | Terminal multiplexer                       |
| `nvim`   | Modern Vim alternative                     |
| `fzf`    | Fuzzy file finder                          |
| `ripgrep`| Fast recursive search                      |
| `bat`    | Syntax-highlighted `cat`                   |
| `jq`     | JSON processor                             |
| `htop`   | Interactive process viewer                 |
| `ncdu`   | Disk usage viewer                          |

---

## 🧪 Tested On

- ✅ Ubuntu 20.04, 22.04
- ✅ Debian 11
- ✅ CentOS 7, CentOS 8 Stream
- ✅ Rocky Linux 9

---

## 📦 To-Do / Future Plans

- [ ] Ghosty shell installer support
- [ ] Optional dotfiles symlink setup
- [ ] Add support for other distros (Alpine, Amazon Linux)
- [ ] Install plugins for Neovim and Tmux

---

## 📜 License

MIT License. Use it, change it, share it.

---

## 💬 Feedback

Open an issue or PR if you have suggestions, ideas, or improvements!
