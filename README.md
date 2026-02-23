# Pipe Dream (Win16) on NixOS

A declarative Nix flake to run the classic Windows 3.1 version of **Pipe Dream** on modern Linux. It pulls the game zip from internet archive and uses **Wine** for the logic and **Gamescope** to upscale the original low-resolution graphics for modern high-DPI Wayland/X11 screens.

## 🚀 Quick Start

Run it instantly without installing anything:

```bash
nix run github:ilioscio/pipedream

```

## 🛠 Installation (NixOS Overlay)

To add Pipe Dream to your system and have it appear in your application launcher (Wofi/Rofi/KDE Menu), add this to your system flake:

### 1. Add Input

```nix
inputs.pipedream.url = "github:ilioscio/pipedream";

```

### 2. Add Overlay and Package

```nix
{
  nixpkgs.overlays = [ inputs.pipedream.overlays.default ];
  environment.systemPackages = [ pkgs.pipedream ];
}

```

## 📝 Troubleshooting

* **No Sound:** Ensure PipeWire/PulseAudio is running. The flake targets your primary hardware sink monitor.
* **First Run:** It may take a few seconds on the first launch to initialize the 32-bit Wine prefix.
