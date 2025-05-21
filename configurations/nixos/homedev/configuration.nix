# configuration.nix
# 这个文件现在由 flake.nix 引入和管理

# 注意：`pkgs`, `lib`, `config` 和 `inputs` (如果 flake.nix 中传递了)
# 都会自动作为参数传递给这个文件。
{ config, pkgs, lib, inputs, ... }: # `inputs` 参数来自 flake.nix 中的 specialArgs

let
  # 推荐在较新的 NixOS 版本 (如 24.05+) 上使用 nix-ld-rs 以获得更好的兼容性
  nix-ld-package = pkgs.nix-ld-rs;
  proxyServer = "http://127.0.0.1:7890";
  noProxyDomains = "localhost,127.0.0.1,mirrors.tuna.tsinghua.edu.cn";
in
{
  nixpkgs.hostPlatform = "x86_64-linux";

  wsl.enable = true;
  wsl.defaultUser = "yesheng";

  time.timeZone = "Asia/Shanghai";

  # sudo 配置
  security.sudo.wheelNeedsPassword = false;

  # NixOS 系统状态版本
  system.stateVersion = "24.11";

  systemd.services.nix-daemon.environment = {
    HTTP_PROXY = proxyServer;
    HTTPS_PROXY = proxyServer;
    # 如果 TUNA 应该直连（不通过 127.0.0.1:7890 代理）
    NO_PROXY = noProxyDomains;
  };

  networking.proxy = {
    # 这个会同时设置 HTTP_PROXY, HTTPS_PROXY, FTP_PROXY
    default = proxyServer;

    # 或者你可以单独设置：
    # httpProxy = proxyServer;
    # httpsProxy = proxyServer;
    # ftpProxy = proxyServer; # 如果需要

    # 设置不走代理的地址
    noProxy = noProxyDomains;

    # 注意：NixOS 模块会自动处理大小写 (e.g., https_proxy 和 HTTPS_PROXY)
  };

  # Nix 相关设置
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings = {
    substituters = [
      "https://nixcache.reflex-frp.org"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" # TUNA 镜像
      "https://cache.nixos.org/"                               # 官方作为备用
      # ... 其他你需要的 cachix 缓存 ...
    ];
    trusted-public-keys = [
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  environment.shells = with pkgs; [zsh];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.package = nix-ld-package;
  wsl.wslConf = {
    boot.command = "export NIX_LD_LIBRARY_PATH=${nix-ld-package}/lib NIX_LD=${nix-ld-package}/libexec/nix-ld; exec ${pkgs.stdenv.shell} -l";
    # 你可以在这里添加其他 wsl.conf 设置，例如:
    # interop.enabled = lib.mkDefault true; # 通常默认为 true
    # automount.enabled = lib.mkDefault true;
  };



  # 系统全局安装的软件包
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    openssh
    git
    htop
    tmux
    unzip
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
  };

  networking.hostName = "nixos";
}
