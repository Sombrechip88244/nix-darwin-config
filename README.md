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
git clone YOUR_REPO_URL ~/.config/nix-darwin
cd ~/.config/nix-darwin
```

> **Important**: Replace `YOUR_REPO_URL` with the actual URL of your nix-darwin configuration repository.

### Your flake.nix should look like this:

```nix
{
  description = "My nix-darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile
      environment.systemPackages = with pkgs; [
        vim
        git
        curl
        wget
        htop
        tree
        ripgrep
        fd
        bat
        exa
        fzf
        jq
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
      
      # macOS system settings
      system.defaults = {
        # Dock settings
        dock = {
          autohide = true;
          orientation = "bottom";
          showhidden = true;
          mineffect = "genie";
          launchanim = true;
          show-process-indicators = true;
          tilesize = 48;
          static-only = true;
          mru-spaces = false;
        };

        # Finder settings
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          CreateDesktop = false;
          FXDefaultSearchScope = "SCcf"; # Search current folder
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "Nlsv"; # List view
          ShowPathbar = true;
          ShowStatusBar = true;
        };

        # Trackpad settings
        trackpad = {
          Clicking = true; # Tap to click
          TrackpadRightClick = true;
          TrackpadThreeFingerDrag = true;
        };

        # NSGlobalDomain settings (affects all apps)
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark"; # Dark mode
          AppleKeyboardUIMode = 3; # Full keyboard access
          ApplePressAndHoldEnabled = false; # Disable press-and-hold for accent characters
          AppleShowAllExtensions = true;
          AppleShowScrollBars = "Always";
          InitialKeyRepeat = 14; # Faster key repeat
          KeyRepeat = 1; # Faster key repeat
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
          NSNavPanelExpandedStateForSaveMode = true;
          NSNavPanelExpandedStateForSaveMode2 = true;
          _HIHideMenuBar = false;
        };

        # Login window settings
        loginwindow = {
          GuestEnabled = false;
          SHOWFULLNAME = false;
        };

        # Screenshots
        screencapture = {
          location = "~/Desktop/Screenshots";
          type = "png";
        };
      };

      # Keyboard settings
      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };
    };
  in
  {
    darwinConfigurations."YOUR_HOSTNAME" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
```

> **Important**: Replace `YOUR_USERNAME` with your actual username and `YOUR_HOSTNAME` with your computer's hostname.

Find your username: `whoami`  
Find your hostname: `hostname` or `scutil --get ComputerName`

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
