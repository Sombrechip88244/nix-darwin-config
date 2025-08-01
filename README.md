# Nix Darwin + Home Manager Setup Guide

A comprehensive guide to setting up a declarative macOS configuration using nix-darwin and Home Manager.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Step 1: Install Nix](#step-1-install-nix)
- [Step 2: Install nix-darwin](#step-2-install-nix-darwin)
- [Step 3: Create Initial Configuration](#step-3-create-initial-configuration)
- [Step 4: Add Home Manager](#step-4-add-home-manager)
- [Step 5: Configure Home Manager](#step-5-configure-home-manager)
- [Step 6: Version Control](#step-6-version-control)
- [Usage](#usage)
- [Common Configurations](#common-configurations)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- macOS (Intel or Apple Silicon)
- Administrative access to your Mac
- Basic familiarity with command line

## Step 1: Install Nix

### Install the Nix package manager:

```bash
sh <(curl -L https://nixos.org/nix/install)
```

### Restart your terminal or source the profile:

```bash
source ~/.nix-profile/etc/profile.d/nix.sh
```

### Verify installation:

```bash
nix --version
```

## Step 2: Install nix-darwin

### Add the nix-darwin channel:

```bash
nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
nix-channel --update
```

### Install nix-darwin:

```bash
$(nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer --no-out-link)/bin/darwin-installer
```

### Source the new environment:

```bash
source /etc/static/bashrc
```

## Step 3: Create Initial Configuration

### Create a configuration directory:

```bash
mkdir -p ~/.config/nix-darwin
cd ~/.config/nix-darwin
```

### Initialize as a git repository:

```bash
git init
```

### Create a flake.nix file:

```nix
{
  description = "My nix-darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile
      environment.systemPackages = with pkgs; [
        vim
        git
        curl
        wget
      ];

      # Enable nix flakes
      nix.settings.experimental-features = "nix-command flakes";
      
      # Enable nix-daemon service
      services.nix-daemon.enable = true;
      
      # Create /etc/zshrc that loads the nix-darwin environment
      programs.zsh.enable = true;
      
      # Set Git commit hash for darwin-version
      system.configurationRevision = self.rev or self.dirtyRev or null;
      
      # Used for backwards compatibility
      system.stateVersion = 4;
      
      # The platform the configuration will be used on
      nixpkgs.hostPlatform = "aarch64-darwin"; # Change to "x86_64-darwin" for Intel Macs
      
      # Configure users - REPLACE WITH YOUR USERNAME
      users.users.YOUR_USERNAME = {
        name = "YOUR_USERNAME";
        home = "/Users/YOUR_USERNAME";
      };
      
      # Enable Home Manager
      home-manager.backupFileExtension = "backup";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.YOUR_USERNAME = import ./home.nix;
    };
  in
  {
    darwinConfigurations."YOUR_HOSTNAME" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
      ];
    };
  };
}
```

> **Important**: Replace `YOUR_USERNAME` with your actual username and `YOUR_HOSTNAME` with your computer's hostname.

Find your username: `whoami`  
Find your hostname: `hostname` or `scutil --get ComputerName`

## Step 4: Add Home Manager

Home Manager is already included in the flake above. Now create the Home Manager configuration.

### Create home.nix:

```nix
{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "YOUR_USERNAME"; # Replace with your username
  home.homeDirectory = "/Users/YOUR_USERNAME"; # Replace with your username

  # This value determines the Home Manager release that your configuration is compatible with
  home.stateVersion = "24.05";

  # Install packages with Home Manager
  home.packages = with pkgs; [
    # Terminal utilities
    htop
    tree
    ripgrep
    fd
    bat
    exa
    fzf
    jq
    
    # Development tools
    nodejs
    python3
    
    # Add any other packages you want
  ];

  # Configure programs
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.default = "simple";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      grep = "rg";
      cat = "bat";
      ls = "exa";
    };
  };

  # Set environment variables
  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
```

## Step 5: Configure Home Manager

You can disable the version mismatch warning by adding this to your `home.nix`:

```nix
home.enableNixpkgsReleaseCheck = false;
```

## Step 6: Version Control

### Add files to git:

```bash
git add flake.nix home.nix
git commit -m "Initial nix-darwin + home-manager configuration"
```

### Create a .gitignore:

```bash
echo "result" > .gitignore
echo ".DS_Store" >> .gitignore
git add .gitignore
git commit -m "Add .gitignore"
```

## Usage

### Build and apply configuration:

```bash
sudo darwin-rebuild switch --flake .#YOUR_HOSTNAME
```

### Update flake inputs:

```bash
nix flake update
sudo darwin-rebuild switch --flake .#YOUR_HOSTNAME
```

### Just rebuild Home Manager:

```bash
home-manager switch --flake .#YOUR_HOSTNAME
```

## Common Configurations

### Shell Configuration (Zsh with Oh My Zsh):

```nix
programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;
  
  oh-my-zsh = {
    enable = true;
    plugins = [ "git" "sudo" "docker" "kubectl" ];
    theme = "robbyrussell";
  };
  
  shellAliases = {
    ll = "ls -l";
    la = "ls -la";
    ".." = "cd ..";
    "..." = "cd ../..";
  };
};
```

### Development Environment:

```nix
programs.direnv = {
  enable = true;
  enableZshIntegration = true;
  nix-direnv.enable = true;
};

programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
};

programs.tmux = {
  enable = true;
  shortcut = "a";
  baseIndex = 1;
  newSession = true;
  escapeTime = 0;
};
```

### macOS System Settings:

Add to your main configuration in `flake.nix`:

```nix
# macOS system settings
system.defaults = {
  dock.autohide = true;
  dock.mru-spaces = false;
  finder.AppleShowAllExtensions = true;
  finder.FXPreferredViewStyle = "clmv";
  loginwindow.LoginwindowText = "Welcome to my Mac";
  screencapture.location = "~/Pictures/Screenshots";
  screensaver.askForPasswordDelay = 10;
};
```

## Troubleshooting

### Common Issues:

1. **"error: path does not exist"**: Make sure all files are committed to git
   ```bash
   git add .
   git commit -m "Add missing files"
   ```

2. **Version mismatch warnings**: Add `home.enableNixpkgsReleaseCheck = false;` to `home.nix`

3. **Permission denied**: Make sure you're using `sudo` for `darwin-rebuild`

4. **Syntax errors**: Validate your nix files:
   ```bash
   nix flake check
   ```

### Useful Commands:

```bash
# Check flake syntax
nix flake check

# Show what would be built
sudo darwin-rebuild build --flake .#YOUR_HOSTNAME

# View current generation
darwin-rebuild --list-generations

# Rollback to previous generation
sudo darwin-rebuild rollback
```

## File Structure

Your final directory structure should look like:

```
~/.config/nix-darwin/
├── flake.nix          # Main system configuration
├── home.nix           # Home Manager configuration
├── flake.lock         # Lock file (auto-generated)
├── .gitignore         # Git ignore file
└── README.md          # This documentation
```

## Benefits

- **Declarative**: Your entire system configuration is defined in code
- **Reproducible**: Easy to recreate the same environment on different machines
- **Version Controlled**: Track changes and roll back if needed
- **Modular**: Separate system and user configurations
- **Cross-Platform**: Same configuration syntax as NixOS

## Next Steps

1. Customize the configurations to match your preferences
2. Add more programs and packages as needed
3. Explore the extensive Home Manager options
4. Consider creating modules for complex configurations
5. Set up automatic updates or deployment workflows

For more advanced configurations, check out:
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [nix-darwin Options](https://daiderd.com/nix-darwin/manual/index.html)
- [Nix Language Guide](https://nixos.org/guides/nix-language.html)
