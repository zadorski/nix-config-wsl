{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # opentofu              # add these to direnv/devenv instead
    # terraform             # add these to direnv/devenv instead
    terraform-docs
    terraform-compliance
  ];
}
