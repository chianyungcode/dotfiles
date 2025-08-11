# Arch Linux Automated Installation

This folder contains configuration files for automated Arch Linux installation using `archinstall`.

## Usage

To perform an automated installation using these configuration files, use the following command:

```bash
archinstall --config https://raw.githubusercontent.com/chianyungcode/chezmoi/others/arch-linux/user_configuration.json --creds https://raw.githubusercontent.com/chianyungcode/chezmoi/others/arch-linux/user_credentials.json
```

## Files

- **user_configuration.json**: Contains the main installation configuration including disk partitioning, packages, and system settings
- **user_credentials.json**: Contains user account credentials and sensitive configuration data

## Customization Required

Before using these configuration files, you **MUST** customize the following sections:

### 1. Disk Configuration (`disk_config`)
In `user_configuration.json`, locate the `disk_config` section and modify:

- **Device name**: Change `/dev/nvme0n1` to your actual disk device (e.g., `/dev/sda`, `/dev/nvme1n1`)
- **Partition sizes**: Adjust the size values for each partition according to your needs
- **Partition labels**: Update the mount points and labels as desired

Example:
```json
"disk_config": {
    "/dev/nvme0n1": {
        "partitions": [
            {
                "size": "512MiB",
                "mountpoint": "/boot",
                "filesystem": "fat32"
            },
            {
                "size": "100GiB",
                "mountpoint": "/",
                "filesystem": "ext4"
            },
            {
                "size": "8GiB",
                "mountpoint": null,
                "filesystem": "swap"
            }
        ]
    }
}
```

### 2. Packages (`packages`)
In `user_configuration.json`, locate the `packages` array and add/remove packages as needed:

```json
"packages": [
    "base",
    "base-devel",
    "linux",
    "linux-firmware",
    "vim",
    "git",
    "networkmanager",
    "grub",
    "efibootmgr",
    "YOUR_CUSTOM_PACKAGES_HERE"
]
```

### 3. User Credentials (`user_credentials.json`)
In `user_credentials.json`, update:

- **Username**: Change `"username": "your_username"`
- **Password**: Change `"!password": "your_password"`
- **Hostname**: Change `"hostname": "your-hostname"`

## Prerequisites

1. Boot from Arch Linux ISO
2. Ensure internet connectivity
3. Identify your disk device name using `lsblk` or `fdisk -l`
4. Customize the configuration files as described above
5. Run the installation command

## Notes

- These configuration files are designed for automated installation
- **Always review and customize the configuration files before use**
- The credentials file contains sensitive information - handle appropriately
- Make sure your disk device names and partition sizes match your actual hardware