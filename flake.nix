{
  description = "Pipe Dream: A classic 16-bit Windows game packaged for modern nix systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # The game logic wrapped into a function for the overlay
      mkPipedream = pkgs: let
        gameFiles = pkgs.fetchzip {
          url = "https://archive.org/download/win3_PipeDr3x/win3_PipeDr3x.zip";
          sha256 = "sha256-TWqlyjE0TizfdoKUqiX68Gs7/C/4lTwysZMsCPjnqKc="; 
          stripRoot = false;
        };
        
        # Create a .desktop file so it shows up in App Launchers
        desktopItem = pkgs.makeDesktopItem {
          name = "pipedream";
          exec = "pipedream";
          icon = "${./icon-pipedream.png}"; # Generic icon, or point to a PNG in your repo
          desktopName = "Pipe Dream";
          categories = [ "Game" ];
        };

        launcher = pkgs.writeShellScriptBin "pipedream" ''
          export WINEPREFIX="$HOME/.local/share/wine-pipedream"

          ${pkgs.gamescope}/bin/gamescope -W 640 -H 480 -w 1280 -h 960 -S integer -- \
            ${pkgs.writeShellScript "wine-launcher" ''
              unset WAYLAND_DISPLAY
              export DISPLAY=:0
              export WINEDEBUG=-all
              export WINEDLLOVERRIDES="mscoree,mshtml="
              ${pkgs.wineWow64Packages.stable}/bin/wine "${gameFiles}/PIPE.EXE"
            ''}
        '';
      in pkgs.symlinkJoin {
        name = "pipedream-full";
        paths = [ launcher desktopItem ];
      };

    in {
      # 1. Provide the overlay
      overlays.default = final: prev: {
        pipedream = mkPipedream prev;
      };

      # 2. Keep the apps/packages for 'nix run'
      packages.${system}.default = mkPipedream pkgs;
      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/pipedream";
      };
    };
}
