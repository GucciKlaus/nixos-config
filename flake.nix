{
  description = "Kernel drifting";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      pc = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./configuration.nix
        ];
      };
    };

    formatter.${system} = pkgs.alejandra;
  };
}
