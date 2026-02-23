{
  description = "Pipe Dream: A classic 16-bit Windows game";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Supporting x86_64 is standard for Wine/16-bit games
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Fetch the game assets
      gameFiles = pkgs.fetchzip {
        url = "https://archive.org/download/win3_PipeDr3x/win3_PipeDr3x.zip";
        sha256 = "sha256-TWqlyjE0TizfdoKUqiX68Gs7/C/4lTwysZMsCPjnqKc="; 
        stripRoot = false;
      };

      # The actual game launcher script
      pipedream-run = pkgs.writeShellScriptBin "pipedream" ''
        export WINEPREFIX="$HOME/.local/share/wine-pipedream"
        
        # Cleanup old prefix to avoid 32/64-bit architecture mismatch
        if [ -d "$WINEPREFIX" ]; then
           rm -rf "$WINEPREFIX"
        fi
        mkdir -p "$WINEPREFIX"

        # The Slayer Trap: Kills everything on exit
        trap '${pkgs.wineWow64Packages.stable}/bin/wineserver -k; killall gamescope 2>/dev/null || true' EXIT

        ${pkgs.gamescope}/bin/gamescope \
          -W 640 -H 480 \
          -w 1280 -h 960 \
          -S integer \
          -- \
          ${pkgs.writeShellScript "wine-launcher" ''
            unset WAYLAND_DISPLAY
            unset XDG_SESSION_TYPE
            export DISPLAY=:0
            export WINEDEBUG=-all
            export WINEDLLOVERRIDES="mscoree,mshtml="
            
            ${pkgs.wineWow64Packages.stable}/bin/wineboot -i
            ${pkgs.wineWow64Packages.stable}/bin/wine "${gameFiles}/PIPE.EXE"
            ${pkgs.wineWow64Packages.stable}/bin/wineserver -k
          ''}
      '';

    in {
      # This allows 'nix build'
      packages.${system}.default = pipedream-run;

      # This allows 'nix run'
      apps.${system}.default = {
        type = "app";
        program = "${pipedream-run}/bin/pipedream";
      };
      
      # For backward compatibility with older Nix commands
      defaultPackage.${system} = self.packages.${system}.default;
    };
}
