{
  description = "NixOs configuration for nonename";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let  
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nonename = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
  
        modules = [
          ./pc/configuration.nix
          ./pc/hardware-configuration.nix

          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.nonename = import ./home/home.nix;
          }
        ];
      }; 
    };            
}
