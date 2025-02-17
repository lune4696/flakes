{
  description = "esp-zig development environment with nix flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    esp-overlay = {
      url = "github:mirrexagon/nixpkgs-esp-dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig-shell = {
      url = "github:lune4696/flakes?dir=zig";
    }; 
  };

  outputs = { self, nixpkgs, esp-overlay, zig-shell }: 
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
       let
        overlays = [ esp-overlay.overlays.default ];
        pkgs = import nixpkgs { inherit system overlays; config.allowUnfree = true; };  
        # allowUnfree = true: For Intel MKL, NVIDIA cuda
       in {
        default = pkgs.mkShell {
          inputsFrom = [zig-shell.devShells.${system}.default esp-overlay.devShells.${system}.esp-idf-full];

          packages = with pkgs; [ mkl ];

          shellHook = ''
            export PATH=${self}/bin:$PATH
            export PS1="\n⛄\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$ \[\033[0m\]"
            clear
            echo -e "\nWelcome to zig-esp devShell!"
          '';
        };
      });
    };
}

