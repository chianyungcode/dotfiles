#!/usr/bin/env bash

# ██╗  ██╗ █████╗ ███╗   ██╗ █████╗ ████████╗ █████╗
# ██║ ██╔╝██╔══██╗████╗  ██║██╔══██╗╚══██╔══╝██╔══██╗
# █████╔╝ ███████║██╔██╗ ██║███████║   ██║   ███████║
# ██╔═██╗ ██╔══██║██║╚██╗██║██╔══██║   ██║   ██╔══██║
# ██║  ██╗██║  ██║██║ ╚████║██║  ██║   ██║   ██║  ██║
# ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
#
#

set -e

echo "Starting uinput configuration and kanata service setup..."

# 1. Create uinput group if it doesn't exist
if ! getent group uinput >/dev/null; then
  echo "Creating group 'uinput'..."
  sudo groupadd uinput
else
  echo "Group 'uinput' already exists."
fi

# 2. Add current user to 'input' and 'uinput' groups
echo "Adding user $USER to groups 'input' and 'uinput'..."
sudo usermod -aG input "$USER"
sudo usermod -aG uinput "$USER"

# 3. Write udev rule for uinput device
echo "Writing udev rule for uinput..."
echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-input.rules >/dev/null

# 4. Reload udev rules and trigger
echo "Reloading udev rules and triggering..."
sudo udevadm control --reload-rules
sudo udevadm trigger

# 5. Load uinput kernel module
echo "Loading uinput kernel module..."
sudo modprobe uinput

# 6. Reload systemd user daemon and manage kanata.service
echo "Reloading systemd user daemon and managing kanata.service..."
systemctl --user daemon-reload
systemctl --user enable kanata.service
systemctl --user start kanata.service

# 7. Show status of kanata.service
echo "Status of kanata.service:"
systemctl --user status kanata.service --no-pager

echo "Done."

# FONTS

mkdir -p ~/.local/share/fonts

src_dir=~/Documents/my-fonts
dest_base=~/.local/share/fonts

mkdir -p "$dest_base"

for font_folder in "$src_dir"/*; do
  if [ -d "$font_folder" ]; then
    folder_name=$(basename "$font_folder")
    dest_folder="$dest_base/$folder_name"
    mkdir -p "$dest_folder"
    cp "$font_folder"/*.otf "$dest_folder"/
    echo "Copied fonts from $font_folder to $dest_folder"
  fi
done

fc-cache -fv
