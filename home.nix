{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "oliverfildes";
  home.homeDirectory = "/Users/oliverfildes";

  # This value determines the Home Manager release that your configuration is
  # compatible with
  home.stateVersion = "24.05";

  # Install packages with Home Manager
  home.packages = with pkgs; [
    # Add any user-specific packages here
    htop
    tree
    ripgrep
    bat
  ];

  # Configure programs
  programs.git = {
    enable = true;
    userName = "Oliver Fildes";
    userEmail = "Oliver.fildes@proton.me";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

# Defualts
home.sessionVariables = {
  TERMINAL = "alacritty";
  EDITOR = "nvim"; # or whatever editor you prefer
};

# programs.zsh = {
#  enable = false;
  
  # Source your existing .zshrc
  initExtra = ''
    if [ -f ~/.zshrc ]; then
      source ~/.zshrc
    fi
  '';
};
}
