#!/usr/bin/env bash
# Usage: sudo bash install_packages_debian.sh
# Installs all manually-added packages from the original Debian setup.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: run with sudo: sudo bash $0"
  exit 1
fi

step() { echo; echo "──> $*"; }
ok()   { echo "    [ok] $*"; }
skip() { echo "    [skip] $*"; }

# ── 1. Base tools ─────────────────────────────────────────────────────────────
step "Base tools"
apt-get update -qq
apt-get install -y \
  apt-transport-https \
  build-essential \
  curl \
  git \
  gnupg \
  htop \
  jq \
  lsb-release \
  netcat-openbsd \
  net-tools \
  nmap \
  openssh-client \
  putty-tools \
  python3 \
  python3-dev \
  python3-pip \
  stow \
  sudo \
  tcpdump \
  tmux \
  traceroute \
  unzip \
  vim \
  wget \
  zsh
ok "base tools installed"

# ── 2. Ansible ────────────────────────────────────────────────────────────────
step "Ansible"
if ! command -v ansible &>/dev/null; then
  apt-get install -y ansible
  ok "ansible installed"
else
  skip "ansible already installed ($(ansible --version | head -1))"
fi

# ── 3. Docker ─────────────────────────────────────────────────────────────────
step "Docker"
if ! command -v docker &>/dev/null; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -qq
  apt-get install -y \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin
  ok "docker installed"
else
  skip "docker already installed ($(docker --version))"
fi

# ── 4. Terraform ──────────────────────────────────────────────────────────────
step "Terraform"
if ! command -v terraform &>/dev/null; then
  wget -qO /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    https://apt.releases.hashicorp.com/gpg

  echo \
    "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list

  apt-get update -qq
  apt-get install -y terraform
  ok "terraform installed"
else
  skip "terraform already installed ($(terraform version | head -1))"
fi

# ── 5. Node.js (via NodeSource LTS) ──────────────────────────────────────────
step "Node.js"
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  apt-get install -y nodejs
  ok "node $(node --version) / npm $(npm --version) installed"
else
  skip "node already installed ($(node --version))"
fi

# ── 6. Neovim ────────────────────────────────────────────────────────────────
step "Neovim"
if ! command -v nvim &>/dev/null; then
  # Use the official AppImage for the latest stable release
  NVIM_VERSION=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
  curl -fsSLo /tmp/nvim.appimage \
    "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage"
  chmod +x /tmp/nvim.appimage
  mv /tmp/nvim.appimage /usr/local/bin/nvim
  ok "neovim ${NVIM_VERSION} installed"
else
  skip "neovim already installed ($(nvim --version | head -1))"
fi

echo
echo "All packages installed. Run setup_dotfiles_debian.sh to apply dotfiles."
