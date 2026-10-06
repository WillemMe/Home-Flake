{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.git;
in {
  options.modules.git = {enable = mkEnableOption "git";};
  config = mkIf cfg.enable {
    #Include packages
    home.packages = with pkgs; [
      diff-so-fancy
    ];

    home.file.".config/git/ignore".source = ./ignore;
    home.file.".config/git/commit-template.txt".source = ./commit-template.txt;

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = lib.mkDefault "Your Name";
          email = lib.mkDefault "you@example.com";
        };
        init = {defaultBranch = "main";};
        core = {
          excludesfile = ".config/git/ignore";
          compression = 9;
          whitespace = "error";
          preloadindex = true;
        };
        url = {
          # Shorthand for your own git server: `git clone mine:repo`
          "git@git.example.com:myuser" = {
            insteadOf = "mine:";
          };
          "git@github.com:" = {
            insteadOf = "gh:";
          };
        };
        status = {
          branch = true;
          showStash = true;
          showUntrackedFiles = "all";
        };
        diff = {
          context = 3;
          renames = "copies";
          interHunkContext = 10;
        };
        interactive = {
          diffFilter = "diff-so-fancy --patch";
          singlekey = true;
        };
        pager = {
          diff = "diff-so-fancy | $PAGER";
        };
        color = {
          diff = {
            meta = "black bold";
            frag = "magenta";
            context = "white";
            whitespace = "yellow reverse";
            old = "red";
          };
          decorate = {
            HEAD = "red";
            branch = "blue";
            tag = "yellow";
            remoteBranch = "magenta";
          };
        };
        commit = {
          template = "~/.config/git/commit-template.txt";
        };
        push = {
          autoSetupRemote = true;
          default = "current";
          followTags = true;
        };
        pull = {
          default = "current";
        };
        rebase = {
          autoStash = true;
          missingCommitsCheck = "warn";
        };
        log = {
          abbrevCommit = true;
          graphColors = "blue,yellow,cyan,magenta,green,red";
        };
      };
    };
  };
}
