{ pkgs, ... }:

{
  fonts.packages = with pkgs; [ # install fonts
    nerd-fonts.symbols-only
    sarasa-gothic
    cascadia-code
  ];
}
