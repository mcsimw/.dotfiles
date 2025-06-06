{
  inputs,
  self,
  ...
}:
{
  imports = [
    inputs.nixpkgs.nixosModules.readOnlyPkgs
    self.modules.nixos.mcsimw
    inputs.preservation.nixosModules.default
    inputs.hjem.nixosModules.default
  ];
  hjem = {
    extraModules = [ inputs.hjem-rum.hjemModules.default ];
    clobberByDefault = true;
  };
  preservation = {
    preserveAt."/persist" = {
      directories = [
        "/var/log"
        "/var/lib/systemd/coredump"
      ];
      files = [
        {
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
      ];
    };
  };
}
