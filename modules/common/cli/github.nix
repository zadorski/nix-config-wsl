{
  config,
  pkgs,
  lib,
  ...
}:

{
  home-manager.users.${config.user} = {
    # automatically enable GitHub CLI if git is enabled
    programs.gh = lib.mkIf config.home-manager.users.${config.user}.programs.git.enable {
      enable = true;
      gitCredentialHelper.enable = true;
      settings.git_protocol = "https";
      extensions = [ ];
    };

    programs.fish = lib.mkIf config.home-manager.users.${config.user}.programs.gh.enable {
      shellAbbrs = {
        ghr = "gh repo view -w";
        gha = "gh run list | head -1 | awk '{ print \\$\\(NF-2\\) }' | xargs gh run view";
        grw = "gh run watch";
        grf = "gh run view --log-failed";
        grl = "gh run view --log";
        ghpr = "gh pr create && sleep 3 && gh run watch";

        # https://github.com/cli/cli/discussions/4067
        prs = "gh search prs --state=open --review-requested=@me";
      };
    };
  };
}
