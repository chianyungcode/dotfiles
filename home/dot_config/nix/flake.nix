{
  description = "Chian Yung nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    # nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Optional: Declarative tap management
    # homebrew-core = {
    #   url = "github:homebrew/homebrew-core";
    #   flake = false;
    # };
    # homebrew-cask = {
    #   url = "github:homebrew/homebrew-cask";
    #   flake = false;
    # };
    # homebrew-bundle = {
    #   url = "github:homebrew/homebrew-bundle";
    #   flake = false;
    # };
  };

  # Add nix-homebrew to outputs if you want to use homebrew with nix
  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      mac-app-util,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.php
            pkgs.chezmoi
            pkgs.proto
            pkgs.rainfrog
            pkgs.nixfmt-rfc-style
            # pkgs.chezmoi
          ];

          #  homebrew = {
          #     enable = true;

          #     casks = [
          #     "iina"
          #     ];

          #     brews = [ "presenterm" ];
          #   };

          #
          nixpkgs.config.allowUnfree = true;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          # System configuration MacOS
          # https://github.com/LnL7/nix-darwin/blob/678b22642abde2ee77ae2218ab41d802f010e5b0/modules/system/defaults/dock.nix
          system = {
            defaults = {
              dock = {
                autohide = true;
                show-recents = false;
                tilesize = 30;
                autohide-delay = 0.24;
                autohide-time-modifier = 1.0;
                magnification = true;
                largesize = 24;
              };
              finder = {
                AppleShowAllFiles = true;
              };
              controlcenter = {
                Bluetooth = false;
              };
            };
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#mbp-m1-chianyung
      # darwinConfiguration."$HOSTNAME"
      darwinConfigurations."Macbook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          mac-app-util.darwinModules.default
          # nix-homebrew.darwinModules.nix-homebrew
          # {
          #   nix-homebrew = {
          #     # Install Homebrew under the default prefix
          #     enable = true;

          #     # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
          #     enableRosetta = true;

          #     taps = {
          #       "homebrew/homebrew-core" = inputs.homebrew-core;
          #       "homebrew/homebrew-cask" = inputs.homebrew-cask;
          #       "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
          #     };

          #     # User owning the Homebrew prefix
          #     user = "chianyung";

          #     # Automatically migrate existing Homebrew installations
          #     autoMigrate = true;
          #   };
          # }
        ];
      };
    };
}
