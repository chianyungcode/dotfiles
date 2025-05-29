#!/bin/bash

set -e # Berhenti jika ada error

echo "Memulai instalasi beberapa tools di macOS..."

# Fungsi untuk memeriksa apakah sebuah perintah sudah terinstall
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Homebrew jika belum ada
install_homebrew() {
  if ! command_exists brew; then
    echo "Menginstal Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "Homebrew sudah terinstall."
  fi
}

# Install NVM & Node.js
install_nvm() {
  if ! command_exists nvm; then
    echo "Menginstal NVM..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    echo "Menginstal Node.js LTS..."
    nvm install --lts
  else
    echo "NVM sudah terinstall."
  fi
}

# Install Docker (via Homebrew)
install_docker() {
  if ! command_exists docker; then
    echo "Menginstal Docker..."
    brew install --cask docker
    echo "Silakan buka aplikasi Docker secara manual pertama kali agar dapat berjalan."
  else
    echo "Docker sudah terinstall."
  fi
}

# Install Neovim
install_neovim() {
  if ! command_exists nvim; then
    echo "Menginstal Neovim..."
    brew install neovim
  else
    echo "Neovim sudah terinstall."
  fi
}

# Install Oh My Zsh
install_ohmyzsh() {
  if ! command_exists zsh; then
    echo "Menginstal Zsh..."
    brew install zsh
  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Menginstal Oh My Zsh..."
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
  else
    echo "Oh My Zsh sudah terinstall."
  fi
}

# Jalankan instalasi
install_homebrew
install_nvm
install_docker
install_neovim
install_ohmyzsh

echo "Instalasi selesai!"
