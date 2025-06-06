{
  flake.modules.nixos.zfs-rollback =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.zfs-rollback;
      cfgZfs = config.boot.zfs;
    in
    {
      options = {
        zfs-rollback = {
          enable = lib.mkEnableOption "Impermanence on safe-shutdown through ZFS snapshots";
          volume = lib.mkOption {
            type = lib.types.str;
            default = null;
            example = "zroot/ROOT/empty";
            description = ''
              Full description to the volume including pool.
              This volume must have a snapshot to an "empty" state.
              WARNING: The volume will be rolled back to the snapshot on every safe-shutdown.
            '';
          };
          snapshot = lib.mkOption {
            type = lib.types.str;
            default = null;
            example = "start";
            description = ''
              Snapshot of the volume in an "empty" state to roll back to.
            '';
          };
        };
      };
      config = lib.mkIf cfg.enable {
        systemd.shutdownRamfs = {
          contents."/etc/systemd/system-shutdown/zpool".source = lib.mkForce (
            pkgs.writeShellScript "zpool-sync-shutdown" ''
              ${cfgZfs.package}/bin/zfs rollback -r "${cfg.volume}@${cfg.snapshot}"
              exec ${cfgZfs.package}/bin/zpool sync
            ''
          );
          storePaths = [ "${cfgZfs.package}/bin/zfs" ];
        };
      };
    };
}
