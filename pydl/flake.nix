{
  description = "Python deep learning development environment with Nix flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
  };

  outputs = { self, nixpkgs }: 
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
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
            # 基本ライブラリ
              stdenv
              pkgconf
              # 線形演算ライブラリ
              blas
              lapack
              # 言語別ライブラリ
              clang
              lld
              llvm
              (python312.withPackages (p: [
                # lsp
                p.python-lsp-server
                # common libs
                p.pandas
                p.numpy
                p.matplotlib
                p.plotly
                # pytorch
                p.torch
                p.torch-geometric
                p.networkx      # グラフ描画用
              ]))
              pyright
              # linux
              alsa-lib          # オーディオ周りを使用する場合は無いとコンパイルできない(はず)
              libxkbcommon      # raylib自体のコンパイルに必要
              # OpenGL
              glfw              # linuxでのウィンドウ周り、無いとコンパイルできない 
              libGLU
              libGL             # OpenGL関連、raylibはOpenGLベースなので無いとコンパイルできない
              freeglut
              # Xorg
              xorg.libX11       # X11絡みの全てに必要、無いとコンパイルできない
              xorg.libXcursor   # 無いとコンパイルできない
              xorg.libXinerama  # 無いとコンパイルできない
              xorg.xinput       # 無いとコンパイルできない
              xorg.libXrandr    # 無いとコンパイルできない
              xorg.libXi        # Ximage, raylib自体のコンパイルに必要
              xorg.libXv        # Xvideo
              xorg.libXext      # raylib自体のコンパイルに必要
              xorg.libXfixes    # raylib自体のコンパイルに必要
              # ユーティリティ
              cloc              # 行数カウンタ
              fzf               # fuzzy finder
              glxinfo           # GPU状態チェック
              helix             # editor
              valgrind          # メモリリークチェック
            ];

            NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.pkgconf ];
            LD_LIBRARY_PATH = "$(nix-build '<nixpkgs>' -A wayland)/lib";

            # 環境変数設定 (オプション)
            ZIG_CACHE_DIR = "./.zig-cache"; # Zigのビルドキャッシュディレクトリ
            ZIG_GLOBAL_CACHE_DIR = "./.global_cache"; # グローバルキャッシュ

            # export NIXPKGS_ALLOW_BROKEN=1はtorchWithRocmの為
            shellHook = ''
              export PATH=${self}/bin:$PATH
              export PS1="\n⛄\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$ \[\033[0m\]"
              clear
              echo -e "\nWelcome to zig devShell!"
            '';
          };
        }
      );
    }; 
}

