{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.services.windscribe;
in
{
  options.services.windscribe = {
    enable = mkEnableOption "windscribe helper";

    package = mkOption {
      type = types.package;
      default = pkgs.windscribe;
      defaultText = "pkgs.windscribe";
      description = "enable daemon for windscribe.";
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "tun" ];
    
    environment.systemPackages = [ cfg.package ];

    networking.firewall.checkReversePath = "loose";

    systemd.services.windscribe = {
      description = "windscribe server daemon.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-pre.target" ];
      before = [ "network-pre.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/opt/windscribe/helper";
        Restart = "always";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ arphe42 ];
}
