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
      
      environment.systemPackages = with pkgs; [
        # Basic tools (git is essential for Zinit)
        vim
        git
        curl
        wget
        
        # Terminal applications
        neovim
        tmux
        neofetch
        
        # Development tools
        nodejs
        python3
        go
        rustc
        cargo
        
        # Terminal utilities
        htop
        tree
        ripgrep
        fd
        bat
        fzf
	yt-dlp
	ffmpeg
        
        # Additional useful tools
        jq           # JSON processor
        yq           # YAML processor  
        unzip        # Archive extraction
        zip          # Archive creation
        gnupg        # GPG encryption
        openssh      # SSH client
        rsync        # File synchronization
        watch        # Run commands repeatedly
        killall      # Kill processes by name
        
        # Zsh dependencies
        zsh          # Zsh shell
      ];

      # Zsh Configuration with Zinit and Powerlevel10k
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableBashCompletion = true;
        
        # Main zsh configuration
        shellInit = ''
          # Shell aliases
          alias rebuild="sudo darwin-rebuild switch --flake ~/.config/nix-darwin#Olivers-MacBook-Air"
          alias rebuild-check="sudo darwin-rebuild build --flake ~/.config/nix-darwin#Olivers-MacBook-Air"
          alias flake-update="cd ~/.config/nix-darwin && nix flake update"
          alias nix-gc="sudo nix-collect-garbage -d"
          alias ls="ls --color"
          alias vim="nvim"
          alias c="clear"
          
          # Powerlevel10k instant prompt
          typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
          
          # Zinit setup
          ZINIT_HOME="''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit/zinit.git"
          if [ ! -d "$ZINIT_HOME" ]; then
             mkdir -p "$(dirname $ZINIT_HOME)"
             git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
          fi
          source "''${ZINIT_HOME}/zinit.zsh"
          
          # Install p10k
          zi ice depth=1; zi light romkatv/powerlevel10k
          
          # Zsh plugins
          zinit light zsh-users/zsh-syntax-highlighting
          zinit light zsh-users/zsh-completions
          zinit light zsh-users/zsh-autosuggestions
          zinit light Aloxaf/fzf-tab
          
          # Oh My Zsh snippets
          zinit snippet OMZL::git.zsh
          zinit snippet OMZP::git
          zinit snippet OMZP::sudo
          zinit snippet OMZP::archlinux
          zinit snippet OMZP::aws
          zinit snippet OMZP::kubectl
          zinit snippet OMZP::kubectx
          zinit snippet OMZP::command-not-found
          
          # Load completions
          autoload -Uz compinit && compinit
          zinit cdreplay -q
          
          # Load p10k config
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
          
          # Keybindings
          bindkey -e
          bindkey '^p' history-search-backward
          bindkey '^n' history-search-forward
          bindkey '^[w' kill-region
          
          # History settings
          HISTSIZE=5000
          HISTFILE=~/.zsh_history
          SAVEHIST=$HISTSIZE
          HISTDUP=erase
          setopt appendhistory
          setopt sharehistory
          setopt hist_ignore_space
          setopt hist_ignore_all_dups
          setopt hist_save_no_dups
          setopt hist_ignore_dups
          setopt hist_find_no_dups
          
          # Completion styling
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zstyle ':completion:*' menu no
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
          
          # Auto-start tmux
          if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
            tmux
          fi
        '';
      };

      # Homebrew configuration
      homebrew = {
        enable = true;
        brews = [
	"docker-compose"
	"emacs"
	"coreutils"
	
	];
        casks = [
          # Applications
          "firefox"
          "visual-studio-code"
          "spotify"
          "alacritty"
	  "raycast"
	  "docker-desktop"
          # Fonts
          "font-0xproto-nerd-font"
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
