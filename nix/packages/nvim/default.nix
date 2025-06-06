{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { pkgs, self', ... }:
    {
      packages.blink-cmp = pkgs.callPackage (
        {
          rustPlatform,
          fetchFromGitHub,
        }:
        rustPlatform.buildRustPackage {
          pname = "blink.cmp";
          version = "1.3.1-unstable-2025-05-21";

          src = fetchFromGitHub {
            owner = "Saghen";
            repo = "blink.cmp";
            rev = "196711b89a97c953877d6c257c62f18920a970f3";
            hash = "sha256-WiS4CZn8OvU01MvSqveZt2FhKznu2FbIlvKP8dZ2cm4=";
          };

          cargoHash = "sha256-IDoDugtNWQovfSstbVMkKHLBXKa06lxRWmywu4zyS3M=";

          # Tries to call git
          preBuild = ''
            rm build.rs
          '';

          postInstall = ''
            cp -r {lua,plugin} "$out"
            mkdir -p "$out/doc"
            cp 'doc/'*'.txt' "$out/doc/"
            mkdir -p "$out/target"
            mv "$out/lib" "$out/target/release"
          '';

          # Uses rust nightly
          env.RUSTC_BOOTSTRAP = true;
          # Don't move /doc to $out/share
          forceShare = [ ];
        }
      ) { };
      packages.nvim = inputs.mnw.lib.wrap pkgs {
        appName = "moo";
        initLua = builtins.readFile ./init.lua;
        aliases = [ "vi" ];
        extraBinPath = with pkgs; [
          lua-language-server
        ];
        plugins = {
          dev.mcsimw.pure = ../../../nvim;
          start = inputs.mnw.lib.npinsToPlugins pkgs ./start.json;
          opt = [
            pkgs.vimPlugins.nvim-treesitter.withAllGrammars
            self'.packages.blink-cmp
          ] ++ inputs.mnw.lib.npinsToPlugins pkgs ./opt.json;
        };
      };
    };
}
