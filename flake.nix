{
  description = "Kraken Desktop - Cryptocurrency trading platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
      let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.${system}.default = pkgs.stdenv.mkDerivation {
          pname = "kraken-desktop";
          version = "0.0.1";

          # this must be built with --impure since old versions are not
          # available for download
          src = builtins.fetchurl {
            url = "https://desktop-downloads.kraken.com/latest/kraken-x86_64-unknown-linux-gnu.zip";
          };

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            wrapGAppsHook
            unzip
          ];

          buildInputs = with pkgs; [
            gtk3
            glib
            cairo
            pango
            gdk-pixbuf
            atk
            libdrm
            xorg.libX11
            xorg.libXcomposite
            xorg.libXdamage
            xorg.libXext
            xorg.libXfixes
            xorg.libXrandr
            xorg.libXrender
            xorg.libXtst
            xorg.libxcb
            xorg.libXi
            xorg.libXcursor
            xorg.libXScrnSaver
            libxkbcommon
            wayland
            mesa
            libGL
            alsa-lib
            nss
            nspr
            expat
            systemd
          ];

          runtimeDependencies = with pkgs; [
            wayland
            libxkbcommon
            mesa
            libGL
          ];

          unpackPhase = ''
            mkdir source
            cd source
            ${pkgs.unzip}/bin/unzip $src
          '';

          installPhase = ''
            mkdir -p $out/bin $out/share/applications $out/share/pixmaps
            
            # Extract and install the binary
            # unzip $src -d $pname
            cp kraken_desktop $out/bin/kraken-desktop-bin
            
            # Create wrapper script for Wayland compatibility
            cat > $out/bin/kraken-desktop << EOF
            #!/bin/sh
            export WAYLAND_DISPLAY=\''${WAYLAND_DISPLAY:-wayland-1}
            export XDG_SESSION_TYPE=wayland
            export QT_QPA_PLATFORM=wayland
            export GDK_BACKEND=wayland
            exec $out/bin/kraken-desktop-bin "\$@"
            EOF
            chmod +x $out/bin/kraken-desktop
            
            # Create desktop entry
            cat > $out/share/applications/kraken-desktop.desktop << EOF
            [Desktop Entry]
            Name=Kraken Desktop
            Comment=Cryptocurrency trading platform
            Exec=$out/bin/kraken-desktop %u
            Icon=kraken-desktop
            Type=Application
            Categories=Office;Finance;
            StartupWMClass=kraken-desktop
            MimeType=x-scheme-handler/kraken;
            EOF
          '';

          meta = with pkgs.lib; {
            description = "Kraken Desktop - Cryptocurrency trading platform";
            homepage = "https://www.kraken.com/desktop";
            license = licenses.free;
            platforms = [ "x86_64-linux" ];
            maintainers = [ ];
          };
        };

        apps.${system}.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/kraken-desktop";
        };
      };
}
