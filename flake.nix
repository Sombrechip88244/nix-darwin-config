{
  description = "Example nix-darwin system flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };
  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {
  # Set the primary user
  system.primaryUser = "oliverfildes";
  
      environment.systemPackages = [
        pkgs.vim
        pkgs.alacritty
        pkgs.neovim
        pkgs.tmux
	pkgs.neofetch
      ];

      # Homebrew configuration
      homebrew = {
        enable = true;
        brews = [
          # Add your desired brew packages here
          # "wget"
          # "curl"
        ];
        casks = [
          # Add your desired cask applications here
          "firefox"
          "font-0xproto-nerd-font"
	  "visual-studio-code"
	  "spotify"
        ];
        masApps = {
          # Add Mac App Store apps here (you'll need their App Store IDs)
          # "Xcode" = 497799835;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # System Defaults Configuration
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

        # Activity Monitor
        ActivityMonitor = {
          IconType = 2; # CPU Usage
          OpenMainWindow = true;
          ShowCategory = 100; # All Processes
        };

        # Menu extras (system menu bar items)
        menuExtraClock = {
          Show24Hour = true;
          ShowAMPM = false;
          ShowDate = 1; # Always show date
          ShowDayOfWeek = true;
          ShowSeconds = false;
        };
      };

      # Keyboard settings
      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };

      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
      
      users.users.oliverfildes = {
        name = "oliverfildes";
        home = "/Users/oliverfildes";
      };
    };
  in
  {
    darwinConfigurations."Olivers-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = "oliverfildes";
          };
        }
      ];
    };
  };
}
