{ inputs, ... }:
{
  imports = [
    inputs.rust-flake.flakeModules.default
    inputs.rust-flake.flakeModules.nixpkgs
    inputs.process-compose-flake.flakeModule
    inputs.cargo-doc-live.flakeModule
  ];
  perSystem = { config, self', pkgs, lib, ... }: {
    rust-project.crates."bevy-breakout".crane =
      let
        # https://github.com/ipetkov/crane/discussions/329#discussioncomment-5978889
        rustToolchain = config.rust-project.toolchain;
        rustPlatform = pkgs.makeRustPlatform {
          inherit (rustToolchain) cargo rustc;
        };
      in
      {
        args.buildInputs = lib.optionals
          pkgs.stdenv.isDarwin
          (with pkgs.darwin.apple_sdk.frameworks; [
            IOKit
            AudioUnit
            CoreAudioKit
            OpenAL
            pkgs.darwin.apple_sdk.Libsystem
          ]);
        args.nativeBuildInputs = with pkgs; [ rustPlatform.bindgenHook ];
      };
    packages.default = self'.packages.bevy-breakout;
  };
}
