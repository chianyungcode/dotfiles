#!/usr/bin/env bash

set -e

# █▄▀ ▄▀█ █▄░█ ▄▀█ ▀█▀ ▄▀█
# █░█ █▀█ █░▀█ █▀█ ░█░ █▀█
#
# ASCII FONTS

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

# █▀▀ █▀█ █▄░█ ▀█▀ █▀
# █▀░ █▄█ █░▀█ ░█░ ▄█

src_dir=~/Documents/my-fonts
dest_base=~/.local/share/fonts

mkdir -p "$dest_base"

for font_folder in "$src_dir"/*; do
  if [ -d "$font_folder" ]; then
    folder_name=$(basename "$font_folder")
    dest_folder="$dest_base/$folder_name"

    if [ -d "$dest_folder" ]; then
      echo "Skipping $folder_name (already exists)"
      continue
    fi

    mkdir -p "$dest_folder"
    cp "$font_folder"/*.otf "$dest_folder"/
    echo "Copied fonts from $font_folder to $dest_folder"
  fi
done

fc-cache -fv

# ▄█ █▀█ ▄▀█ █▀ █▀ █░█░█ █▀█ █▀█ █▀▄   ▄▄   ▀█ █▀▀ █▄░█
# ░█ █▀▀ █▀█ ▄█ ▄█ ▀▄▀▄▀ █▄█ █▀▄ █▄▀   ░░   █▄ ██▄ █░▀█
#
# https://docs.zen-browser.app/guides/1password

sudo mkdir -p /etc/1password
sudo touch /etc/1password/custom_allowed_browsers

if ! grep -qxF "zen-bin" /etc/1password/custom_allowed_browsers; then
  echo "zen-bin" | sudo tee -a /etc/1password/custom_allowed_browsers >/dev/null
fi

# █▀▀ █ █▄░█ █▀▀ █▀▀ █▀█ █▀█ █▀█ █ █▄░█ ▀█▀
# █▀░ █ █░▀█ █▄█ ██▄ █▀▄ █▀▀ █▀▄ █ █░▀█ ░█░

# echo "[1/5] Installing fingerprint packages..."
# sudo pacman -Syu --noconfirm fprintd
#
# echo "[2/5] Enabling fprintd service..."
# sudo systemctl enable fprintd.service --now
#
# echo "[3/5] Setting up PAM for fingerprint authentication..."
#
# # Backup PAM configs if not backed up before
# backup_file() {
#   local file="$1"
#   if [ -f "$file" ] && [ ! -f "$file.bak" ]; then
#     sudo cp "$file" "$file.bak"
#     echo "  → Backup created: $file.bak"
#   fi
# }
#
# backup_file /etc/pam.d/login
# backup_file /etc/pam.d/sudo
# [ -f /etc/pam.d/swaylock ] && backup_file /etc/pam.d/swaylock
# [ -f /etc/pam.d/gtklock ] && backup_file /etc/pam.d/gtklock
#
# # Function to add pam_fprintd at the very top (before other auth rules)
# add_pam_fprintd() {
#   local file="$1"
#   if ! grep -q "pam_fprintd.so" "$file"; then
#     sudo awk '
#             BEGIN {inserted=0}
#             /^#/ {print; next}
#             inserted==0 && /^auth/ {
#                 print "auth      sufficient    pam_fprintd.so"
#                 inserted=1
#             }
#             {print}
#         ' "$file" | sudo tee "$file.tmp" >/dev/null
#     sudo mv "$file.tmp" "$file"
#     echo "  → Added pam_fprintd to top of $file"
#   else
#     echo "  → pam_fprintd already present in $file"
#   fi
# }
#
# add_pam_fprintd /etc/pam.d/login
# add_pam_fprintd /etc/pam.d/sudo
#
# if [ -f /etc/pam.d/swaylock ]; then
#   add_pam_fprintd /etc/pam.d/swaylock
# elif [ -f /etc/pam.d/gtklock ]; then
#   add_pam_fprintd /etc/pam.d/gtklock
# fi
#
# echo "[4/5] Checking existing fingerprints..."
# if fprintd-list "$USER" 2>/dev/null | grep -q "Finger"; then
#   echo "  → Fingerprint already enrolled for user '$USER'. Skipping enrollment."
# else
#   echo "  → No fingerprint found. Starting enrollment..."
#   fprintd-enroll
# fi
#
# echo "[5/5] ✅ Fingerprint setup complete."
# echo "Test with: sudo -k && sudo ls"

# █▀▄ █▀█ █▀▀ █▄▀ █▀▀ █▀█
# █▄▀ █▄█ █▄▄ █░█ ██▄ █▀▄

sudo usermod -aG docker $USER

# █▀▀ █▀ █▀█ ▄▀█ █▄░█ █▀ █▀█
# ██▄ ▄█ █▀▀ █▀█ █░▀█ ▄█ █▄█

systemctl --user enable espanso.service
