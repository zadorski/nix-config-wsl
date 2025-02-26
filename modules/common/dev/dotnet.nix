{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.toolchain.dotnet.enable = lib.mkEnableOption "C# and .NET toolchain";

  config = lib.mkIf config.toolchain.dotnet.enable {
    # currently there's an error with the .NET package as it for some reason depends
    # on the previous version (.NET SDK 6) which is EOL.
    # I have not had the time to fix this, so leaving this here.
    # .NET is also to deeply entrenched with the Von Neuman Architecture
    # to care about leaving the system files as read only.
    # if you know how to fix this, then a PR is welcome 🙂
    assertions = lib.singleton {
      assertion = false;
      message = ''
        The .NET toolchain is currently not supported due to issues with 
        it's dependencies. Please disable this feature or use an
        alternative version of the toolchain.
        If you know how to fix this, then a PR is welcome 🙂
      '';
    };

    home-manager.users.${config.user} = {

      home.packages = with pkgs; [
        msbuild # Microsoft Build Tools
        dotnetCorePackages.dotnet_8.sdk # .NET SDK
      ];

      home.sessionVariables = {
        DOTNET_RUNTIME = pkgs.dotnetCorePackages.dotnet_8.sdk;
      };
    };
  };
}
