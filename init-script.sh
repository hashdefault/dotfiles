#!/bin/bash

install_fundamental_update() {
  echo "Updating the sistem..."
  sudo pacman -Syyuu -y
  echo "DONE"

  echo "Installing required packages..."
  sudo pacman -S git openssh firefox fish kitty curl docker docker-compose nodejs npm libcurl-devel re2c bison sqlite libxml-devel gd-devel g++ oniguruma libpq-devel libzip-devel -y

  curl -sS https://starship.rs/install.sh | sh
  echo "DONE"

  echo "Installing yay..."
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  echo "DONE"
}

install_asdf() {
  echo "Installing asdf package manager..."
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
  cat "source '~/.asdf/asdf.fish'" >>~/.config/fish/config.fish
  echo "DONE"
}

define_user_docker() {
  echo "Setting user to use Docker..."
  usermod -aG docker $USER
  echo "DONE"

}

install_php_asdf() {

  echo "Installing php versions with asdf..."
  asdf plugin add php
  asdf plugin add python
  asdf install php 8.2.0
  asdf install php 7.2.1
  echo "DONE"
}

install_gnome() {
  echo "Installing gnome desktop..."
  sudo pacman -S gnome gnome-session -y

  echo "DONE"
}
install_xmonad() {
  echo "Installing xmonad,xmobar and polybar..."
  sudo pacman -S xmonad xmonad-contrib xmobar polybar -y
  cp -R ~/dotfiles/.config/xmonad ~/.config
  cp -R ~/dotfiles/.config/xmobar ~/.config
  cp -R ~/dotfiles/.config/polybar ~/.config
  echo "DONE"
}

install_rofi() {
  echo "Installing rofi..."
  cp ~/dotfiles/.config/rofi ~/.config/rofi
  sudo pacman -S rofi
  cd /tmp
  git clone git@github.com:newmanls/rofi-themes-collection.git
  cd rofi-themes-colletion/themes
  mkdir -p ~/.local/share/rofi/themes
  echo "DONE"

}
