{ config, lib, pkgs, inputs, nixpkgs-unstable, nur, hyprland, ... }:
let
  user = "nix";
  cpu = "amd";
in
{
  imports = [
    inputs.self.nixosRoles.desktop
    inputs.home-manager.nixosModules.home-manager
  ];
  templates = {
    system = {
      bootEncrypted = {
        enable = true;
        disk = "/dev/disk/by-id/nvme-WDS100T1X0E-00AFY0_21275M801506";
      };
      crypttab = {
        devices = [
          { blkDev="/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S3YVNY0N102380J-part1"; label="data-01"; mountpoint="mnt/data-01"; fsType="btrfs"; }
          { blkDev="/dev/disk/by-id/ata-Samsung_SSD_860_EVO_2TB_S3YVNY0N104101H-part1"; label="data-02"; mountpoint="mnt/data-02"; fsType="btrfs"; }
          { blkDev="/dev/disk/by-id/ata-Samsung_SSD_870_EVO_2TB_S754NX0W410714Y-part1"; label="data-03"; mountpoint="mnt/data-03"; fsType="btrfs"; }
          { blkDev="/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NZFN901822H"; label="data-04"; mountpoint="mnt/data-04"; fsType="btrfs"; }
          { blkDev="/dev/disk/by-id/ata-PLEXTOR_PX-256M5Pro_P02310104307-part1"; label="win11"; }
        ];
      };
    };
    services = {
     kvm = {
        enable = true;
        platform = "${cpu}";
        vfioIds = ["10de:1f08" "10de:10f9"];
        user = "${user}";
      };
      samba = {
        enable = true;
        shares = [
          {name="data-02"; path="/mnt/data-02"; hostsAllow="127.0.0.1 192.168.0.0/16";}
          {name="data-03"; path="/mnt/data-03"; hostsAllow="127.0.0.1 192.168.0.0/16";}
          {name="data-04"; path="/mnt/data-04"; hostsAllow="127.0.0.1 192.168.0.0/16";}
        ];
      };
      podman = {
        enable = true;
        user = "${user}";
      };
    };
  };

  age = {
    secrets = {
      "git.server01.lan" = {
        file = ./secrets/git.server01.lan.age;
        path = "/home/${user}/.ssh/git.server01.lan";
        owner = "${user}";
        group = "users";
        mode = "600";
      };
      "git.server01.lan.pub" = {
        file = ./secrets/git.server01.lan.pub.age;
        path = "/home/${user}/.ssh/git.server01.lan.pub";
        owner = "${user}";
        group = "users";
        mode = "644";
      };
      "git.server02.lan" = {
        file = ./secrets/git.server02.lan.age;
        path = "/home/${user}/.ssh/git.server02.lan";
        owner = "${user}";
        group = "users";
        mode = "600";
      };
      "git.server02.lan.pub" = {
        file = ./secrets/git.server02.lan.pub.age;
        path = "/home/${user}/.ssh/git.server02.lan.pub";
        owner = "${user}";
        group = "users";
        mode = "644";
      };
      "niki-on-github.github.com" = {
        file = ./secrets/niki-on-github.github.com.age;
        path = "/home/${user}/.ssh/niki-on-github.github.com";
        owner = "${user}";
        group = "users";
        mode = "600";
      };
      "niki-on-github.github.com.pub" = {
        file = ./secrets/niki-on-github.github.com.pub.age;
        path = "/home/${user}/.ssh/niki-on-github.github.com.pub";
        owner = "${user}";
        group = "users";
        mode = "644";
      };       
      "ssh.server01.lan" = {
        file = ./secrets/ssh.server01.lan.age;
        path = "/home/${user}/.ssh/ssh.server01.lan";
        owner = "${user}";
        group = "users";
        mode = "600";
      };
      "ssh.server01.lan.pub" = {
        file = ./secrets/ssh.server01.lan.pub.age;
        path = "/home/${user}/.ssh/ssh.server01.lan.pub";
        owner = "${user}";
        group = "users";
        mode = "644";
      };        
      "ssh.server02.lan" = {
        file = ./secrets/ssh.server02.lan.age;
        path = "/home/${user}/.ssh/ssh.server02.lan";
        owner = "${user}";
        group = "users";
        mode = "600";
      };
      "ssh.server02.lan.pub" = {
        file = ./secrets/ssh.server02.lan.pub.age;
        path = "/home/${user}/.ssh/ssh.server02.lan.pub";
        owner = "${user}";
        group = "users";
        mode = "644";
      };    
    };
  };

  sops = {
    defaultSopsFile = ./secrets/secrets.sops.yaml;
    secrets.user-password.neededForUsers = true;
  };

  security.pki.certificateFiles = [
    ./secrets/ca-cert.crt
  ];

  users = {
    users = {
      ${user} = {
        isNormalUser = true;
        description = "nix user";
        createHome = true;
        shell = pkgs.zsh;
        # use `mkpasswd -m sha-512 | tr -d '\n'` to get the password hash for your sops file
        passwordFile = config.sops.secrets.user-password.path;
        home = "/home/${user}";
        extraGroups = [
          "audio"
          "audit"
          "dialout"
          "disk"
          "input"
          "kvm"
          "log"
          "scanner"
          "sshusers"
          "storage"
          "uucp"
          "video"
          "wheel"
        ];
      };
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit nixpkgs-unstable;
      inherit nur;
      inherit hyprland;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      ${user} = import ./home.nix;
    };
  };

  # required for deploy-rs
  nix.settings.trusted-users = [ "root" "${user}" ];

  systemd.tmpfiles.rules = [
    "d /home/${user}/Music"
    "L /home/${user}/Music/database - - - - /mnt/data-01/Musik"
  ];

  environment = {
    loginShellInit = ''
      if [ -f $HOME/.profile ]; then
        source $HOME/.profile
      fi
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
    variables = {
      XDG_CURRENT_DESKTOP="Hyprland";
      XDG_SESSION_TYPE="wayland";
      XDG_SESSION_DESKTOP="Hyprland";
    };
  };

  hardware.cpu."${cpu}".updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
