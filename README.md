# Nix Darwin Setup Guide

A comprehensive guide to setting up a declarative macOS configuration using nix-darwin.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Step 1: Install Nix](#step-1-install-nix)
- [Step 2: Install nix-darwin](#step-2-install-nix-darwin)
- [Step 3: Create Initial Configuration](#step-3-create-initial-configuration)
- [Step 4: Version Control](#step-4-version-control)
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

## Step 3: Clone Configuration Repository

### Clone the nix-darwin configuration repository:

```bash
git clone https://github.com/Sombrechip88244/nix-darwin-config/ ~/.config/nix-darwin
cd ~/.config/nix-darwin
```



## Step 4: Customize Configuration

### Update the configuration for your system:

1. **Edit the flake.nix file** to match your username and hostname:
   ```bash
   vim flake.nix
   ```

2. **Replace placeholders** in the configuration:
   - Replace `YOUR_USERNAME` with your actual username (`whoami`)
   - Replace `YOUR_HOSTNAME` with your computer's hostname (`hostname` or `scutil --get ComputerName`)
   - Update `nixpkgs.hostPlatform` to match your system:
     - `"aarch64-darwin"` for Apple Silicon Macs
     - `"x86_64-darwin"` for Intel Macs

3. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Customize configuration for this machine"
   ```

## Usage

### Initial setup - build and apply configuration:

```bash
sudo darwin-rebuild switch --flake .#YOUR_HOSTNAME
```

### After making changes to the configuration:

```bash
git add .
git commit -m "Description of changes"
sudo darwin-rebuild switch --flake .#YOUR_HOSTNAME
```

### Update flake inputs to get latest packages:

```bash
nix flake update
git add flake.lock
git commit -m "Update flake inputs"
sudo darwin-rebuild switch --flake .#YOUR_HOSTNAME
```

### Push changes back to your repository:

```bash
git push origin main
```

### Just check what would be built without applying:

```bash
sudo darwin-rebuild build --flake .#YOUR_HOSTNAME
```

## Common Configurations

### Adding Development Tools:

```nix
environment.systemPackages = with pkgs; [
  # Basic tools
  vim
  git
  curl
  wget
  
  # Development
  nodejs
  python3
  go
  rustc
  cargo
  
  # Terminal utilities
  htop
  tree
  ripgreg
  fd
  bat
  fzf
  tmux
  
  # Editor
  neovim
  vscode
];
```

### Shell Configuration:

```nix
programs.zsh = {
  enable = true;
  enableCompletion = true;
  enableBashCompletion = true;
  
  # Add custom shell init
  shellInit = ''
    # Custom shell configuration
    export EDITOR=vim
    export BROWSER=firefox
    
    # Aliases
    alias ll='ls -l'
    alias la='ls -la'
    alias grep='rg'
    alias cat='bat'
  '';
};
```

### Git Configuration:

```nix
programs.git = {
  enable = true;
  config = {
    init.defaultBranch = "main";
    user.name = "Your Name";
    user.email = "your.email@example.com";
    push.default = "simple";
    pull.rebase = true;
  };
};
```

### Additional macOS Settings:

```nix
system.defaults = {
  # More dock settings
  dock = {
    autohide = true;
    mru-spaces = false;
    minimize-to-application = true;
    persistent-apps = [
      "/Applications/Firefox.app"
      "/Applications/Alacritty.app"
    ];
  };
  
  # Menu bar
  menuExtraClock = {
    Show24Hour = true;
    ShowAMPM = false;
    ShowDate = 1;
    ShowDayOfWeek = true;
    ShowSeconds = false;
  };
  
  # More finder settings
  finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    CreateDesktop = false;
    FXPreferredViewStyle = "clmv"; # Column view
    ShowPathbar = true;
    ShowStatusBar = true;
  };
  
  # Security
  loginwindow = {
    GuestEnabled = false;
    SHOWFULLNAME = false;
    LoginwindowText = "Welcome to my Mac";
  };
};
```

## Troubleshooting

### Common Issues:

1. **"error: path does not exist"**: Make sure all files are committed to git
   ```bash
   git add .
   git commit -m "Add missing files"
   ```

2. **Permission denied**: Make sure you're using `sudo` for `darwin-rebuild`

3. **Syntax errors**: Validate your nix files:
   ```bash
   nix flake check
   ```

4. **Build failures**: Check the build output and ensure all package names are correct

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

# Search for packages
nix search nixpkgs package_name

# Show package information
nix show-derivation nixpkgs#package_name
```

### Debugging Configuration:

```bash
# Dry run to see what would change
sudo darwin-rebuild build --flake .#YOUR_HOSTNAME

# Verbose output
sudo darwin-rebuild switch --flake .#YOUR_HOSTNAME --show-trace

# Check system configuration
darwin
