{ pkgs, inputs, lib, config, ... }: {
  imports = [
    inputs.nur.hmModules.nur
    inputs.self.homeManagerRoles.desktop
    inputs.personalHyprland.homeManagerModules.default
  ];

  home.activation = {
    dotfiles-setup = lib.hm.dag.entryAfter ["installPackages"] ''
      export PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:$PATH"      
      [ -d ~/.dotfiles ] || git clone --bare ssh://git@git.server01.lan:222/r/nixos-dotfiles.git ~/.dotfiles
      [ -f ~/.profiles ] || git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -f main
      git --git-dir=$HOME/.dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no  
    '';
  };
  
  home.file = {
    "${config.xdg.configHome}/mako/config".enable = lib.mkForce false;
    "${config.xdg.configHome}/hypr/hyprland.conf".enable = lib.mkForce false;
    "${config.programs.zsh.dotDir}/.zshrc".enable = lib.mkForce false;
  };

  home.packages = with pkgs; [
    hyprpaper
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "git.server01.lan" = {
        port = 222;
        hostname = "git.server01.lan";
        user = "git";
        identityFile = "~/.ssh/git.server01.lan";
      };
     "niki-on-github.github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/niki-on-github.github.com";
      };
     "server01.lan" = {
        hostname = "server01.lan";
        user = "arch";
        identityFile = "~/.ssh/ssh.server01.lan";
      };
     "server02.lan" = {
        hostname = "server02.lan";
        user = "git";
        identityFile = "~/.ssh/ssh.server01.lan";
      };
     "git.server02.lan" = {
        hostname = "server02.lan";
        user = "git";
        identityFile = "~/.ssh/git.server02.lan";
      };    
    };  
  };
}
