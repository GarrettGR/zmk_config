{
  description = "Corne ZMK firmware";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);

    src = nixpkgs.lib.sourceFilesBySuffices self [
      ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi"
      ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig"
    ];

    zephyrDepsHash = "sha256-emLUrBuHwtniwD7dtJBOkZwaltHz/n1OCJ35mxY7t38=";
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "corne-firmware";
        inherit src zephyrDepsHash;
        board = "nice_nano//zmk";
        shield = "corne_%PART%";
        meta = {
          description = "Corne ZMK firmware (left + right)";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      settings-reset = zmk-nix.legacyPackages.${system}.buildKeyboard {
        name = "settings-reset";
        inherit src zephyrDepsHash;
        board = "nice_nano//zmk";
        shield = "settings_reset";
        meta = {
          description = "ZMK settings-reset firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
