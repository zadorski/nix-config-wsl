{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.toolchain.infrastructure-as-code.enable = lib.mkEnableOption "Infrastructure as Code tools";

  config = lib.mkIf config.toolchain.infrastructure-as-code.enable {
    unfreePackages = [
      "terraform"
    ];

    home-manager.users.${config.user} = {
      programs.fish.shellAbbrs = {
        "ic" = "terraform";
        "icf" = "terraform";
        "ico" = "tofu";
      };

      home.packages = with pkgs; [
        terraform # Terraform executable
        terraform-ls # Language server
        tflint # Linter

        opentofu # Open Source alternative
      ];
    };
  };
}
