{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; # if the cursor becomes invisible
    NIXOS_OZONE_WL = "1"; # hint electron apps to use Wayland
  };
}
