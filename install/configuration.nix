# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

let
  # 推荐在较新的 NixOS 版本 (如 24.05+) 上使用 nix-ld-rs 以获得更好的兼容性
  nix-ld-package = pkgs.nix-ld-rs;
  proxyServer = "http://127.0.0.1:7890";
  noProxyDomains = "localhost,127.0.0.1,mirrors.tuna.tsinghua.edu.cn";
in
{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  wsl.enable = true;
  wsl.defaultUser = "yesheng";

  networking.hostName = "homedev";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = ["@wheel" "yesheng"];

  # 二进制缓存
  nix.settings.substituters = [
    "https://nixcache.reflex-frp.org" # obelisk 镜像
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" # TUNA 镜像
    "https://cache.nixos.org/"
  ];
  nix.settings.trusted-public-keys = [
    "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];

  systemd.services.nix-daemon.environment = {
    HTTP_PROXY = proxyServer;
    HTTPS_PROXY = proxyServer;
    # 如果 TUNA 应该直连（不通过 127.0.0.1:7890 代理）
    NO_PROXY = noProxyDomains;
  };

  networking.proxy = {
    default = proxyServer;
    noProxy = noProxyDomains;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    python
  ];

  # 用户 "yesheng" 的配置
  users.users.yesheng = {
    isNormalUser = true;
    uid = 1000;
    description = "yesheng";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINukcsirEekCOG/jNb3STPHnMIiB+fpqQGeAfVQJ323B Gitee SSH Key"
    ];
    packages = with pkgs; [
    ];
  };

  # OpenSSH 服务配置
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    # openFirewall = true; # 在 WSL 中，防火墙通常由 Windows 控制，此选项可能不直接生效或非必需
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
