{
  description = "Python deep learning development environment with Nix flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    pydl-shell = {
      url = "github:lune4696/flakes?dir=pydl&ref=sandbox";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
  };

  outputs = { self, nixpkgs, pydl-shell }: 
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

    in {
     # for nix develop command
      devShells = forAllSystems (system: 
        let
          #pkgs = import nixpkgs { inherit system; config.allowBroken = true; };
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          torch-geometric-cuda = pkgs.python312Packages.torch-geometric.override {
            torch = pkgs.python312Packages.torchWithCuda;
          };
        in {
          default = pkgs.mkShell {
            inputsFrom = [pydl-shell.devShells.${system}.default];

            packages = with pkgs; [
            nvtopPackages.nvidia
            # pytorch
            torch-geometric-cuda
            (python312.withPackages (p: [
              p.networkx      # グラフ描画用
            ]))
          ];

            # export NIXPKGS_ALLOW_BROKEN=1はtorchWithRocmの為
            shellHook = ''
              export PATH=${self}/bin:$PATH
              export PS1="\n⛄\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$ \[\033[0m\]"
              clear
              echo -e "\nWelcome to pydl-cuda devShell!"
            '';
          };
        }
      );
    }; 
}

