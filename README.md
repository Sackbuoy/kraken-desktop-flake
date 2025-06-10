# Kraken Desktop Flake
I wanted Kraken desktop on my Nix/Hyprland build - so I made this
This only supports x86_64 linux on wayland, only tested on hyprland

note: kraken only provides a `latest` version so this has to be installed with
`--impure`

You can pull this into another flake like so:
```
{
  description = "My beautiful flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kraken-desktop.url = "github:Sackbuoy/kraken-desktop-flake";
  };

  outputs = {
    self,
    nixpkgs,
    kraken-desktop,
  }:
  let
    system = "x86_64-linux";
    kraken = kraken-desktop.packages.x86_64-linux.default;
    pkgs = import nixpkgs;
  in {
    packages.${system}.default = pkgs.buildEnv {
      paths = [
        kraken
      ];
    };
  };
}


```

Or just install directly with 
```
nix profile install github:Sackbuoy/kraken-desktop-flake --impure
```
