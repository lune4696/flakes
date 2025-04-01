{
  description = "Python deep learning development environment with Nix flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    pydl-shell = {
      url = "github:lune4696/flakes?dir=pydl";
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
          torchWithCudaMKL = pkgs.python312Packages.torchWithCuda.overrideAttrs (old: {
            buildInputs = old.buildInputs ++ [ pkgs.mkl ];
            cmakeFlags = old.cmakeFlags ++ [ "-DUSE_MKL=ON" ];
          });
          torch-geometric-2_5_1 = pkgs.python312Packages.torch-geometric.overrideAttrs (oldAttrs: {
            src = pkgs.fetchFromGitHub {
              owner = "pyg-team";
              repo = "pytorch_geometric";
              rev = "2.5.1";
              hash = "sha256-341pDcevG3KSV3aE2FoXaEWgb/a9N7gI9tQrHKDI4cU";
            };
            propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
              pkgs.python312Packages.scipy
              pkgs.python312Packages.scikit-learn
            ];
          });
          torch-geometric-cuda-2_5_1 = torch-geometric-2_5_1.override {
            torch = torchWithCudaMKL;
          };
          libs = with pkgs; [
            nvtopPackages.nvidia
            # pytorch
            torch-geometric-cuda-2_5_1
            (python312.withPackages (p: [
              p.networkx      # グラフ描画用
            ]))
          ];
        in {
          default = pkgs.mkShell {
            inputsFrom = [pydl-shell.devShells.${system}.default];

            buildInputs = [pkgs.python312Packages.torchWithCuda];
            
            packages = libs;

            NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libs;

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

