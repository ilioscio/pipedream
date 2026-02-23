{
  description = "Pipe Dream for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      gameFiles = pkgs.fetchzip {
        url = "https://archive.org/download/win3_PipeDr3x/win3_PipeDr3x.zip";
        sha256 = "sha256-TWqlyjE0TizfdoKUqiX68Gs7/C/4lTwysZMsCPjnqKc="; 
        stripRoot = false;
      };

    in {
      packages.${system}.default = pkgs.writeShellScriptBin "pipedream" ''
      export WINEPREFIX="$HOME/.local/share/wine-pipedream"
      
      mkdir -p "$WINEPREFIX"

      ${pkgs.gamescope}/bin/gamescope \
        -W 640 -H 480 \
        -w 1280 -h 960 \
        -S integer \
        -- \
        ${pkgs.writeShellScript "wine-launcher" ''
          unset WAYLAND_DISPLAY
          unset XDG_SESSION_TYPE
          export DISPLAY=:0
          
          # SUPPRESS MONO/GECKO:
          # mscoree=d (disables Mono/.NET)
          # mshtml=d (disables Gecko/Internet Explorer engine)
          export WINEDLLOVERRIDES="mscoree,mshtml="
          
          # SILENCE LOGS:
          export WINEDEBUG=-all
          
          ${pkgs.wineWow64Packages.stable}/bin/wineboot -i
          ${pkgs.wineWow64Packages.stable}/bin/wine "${gameFiles}/PIPE.EXE"
          ${pkgs.wineWow64Packages.stable}/bin/wineserver -k
        ''}
    '';

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/pipedream";
      };
    };
}
