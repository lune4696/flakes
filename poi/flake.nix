{
  description = "poi ?";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, }: 
    flake-utils.lib.eachDefaultSystem (
      system: 
      let
        pkgs = import nixpkgs { inherit system; }; 
      in {
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            pkgconf
          ];
          buildInputs = with pkgs; [
            # その他ライブラリ
            glfw              # ウィンドウ
            libGL             # OpenGL関連
            stdenv            # Unix tools, 無いと環境がまともに作れない

            # 補助ライブラリ群
            fzf               # あると便利なので
            glxinfo           # あると便利なので
            p7zip

            # poi依存ライブラリ
            gtk3
            gtk4              # gtk
            nodejs_23
            nss
            nspr
            glib
            dbus
            atk
            cups
            pango
            cairo
            xorg.libX11       # X11絡み
            xorg.libXcomposite
            xorg.libXdamage
            xorg.libXext
            xorg.libXfixes    
            xorg.libXrandr
            xorg.libxcb
            libdrm
            mesa
            expat
            libxkbcommon      
            alsa-lib          # オーディオ
            fontconfig
            udev

            #xorg.libXcursor   
            #xorg.libXinerama  
            #xorg.xinput       
            #xorg.libXi        
          ];

          NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs;[
            pkgconf
            glib
            nss 
            nspr
            dbus
            atk
            cups
            gtk3
            pango
            cairo
            xorg.libX11
            xorg.libXcomposite
            xorg.libXdamage
            xorg.libXext      
            xorg.libXfixes    
            xorg.libXrandr    
            xorg.libxcb
            libdrm
            mesa
            expat
            libxkbcommon      
            alsa-lib
            udev
          ]) ;
          FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";

        };
      }
    ); 
}

