{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = {
    enable = mkEnableOption "zsh";
  };

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    home.packages = with pkgs; [
      libnotify # dependecy for notify-send
      zoxide # the better cd
      fd # better find
      nix-output-monitor # colorful nix build outputs
      eza # better ls
      bat # better cat
      ripgrep # better grep
      jq
      #trashy
      expect
      fzf
      asciinema
    ];
    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };

    programs.zsh = {
      enable = true;

      # directory to put config files in
      dotDir = "${config.xdg.configHome}/zsh";

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      plugins = [
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      # .zshrc
      initContent = ''
        path+=("$HOME/bin")
        path+=("$HOME/.local/bin")
        export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store";
        bindkey '^L' autosuggest-accept

        edir() { tar -cz $1 | age -p > $1.tar.gz.age && rm -rf $1 &>/dev/null && echo "$1 encrypted" }
        ddir() { age -d $1 | tar -xz && rm -rf $1 &>/dev/null && echo "$1 decrypted" }

        logsh() {
          mkdir -p "./99_terminal"
          local ts=$(date +'%Y%m%d_%H%M%S')
          local logfile="./99_terminal/''\${ts}.log"
          echo "[*] logging to $logfile"

          STARSHIP_CONFIG="$HOME/.config/starship-minimal.toml" \
          FZF_DEFAULT_COMMAND= FZF_CTRL_T_COMMAND= FZF_ALT_C_COMMAND= \
          ZOXIDE_CMD= \
          asciinema record -f txt "$logfile"
        }
      '';

      # basically aliases for directories:
      # `cd ~dots` will cd into ~/.config/home-dots
      dirHashes = {
        dots = "$HOME/.config/home-dots";
        dorps-nvim = "$HOME/.config/Dorps-NVIM";
        wordlists = "/usr/share/wordlists/";
      };

      # Tweak settings for history
      history = {
        save = 10000;
        size = 10000;
        path = "$HOME/.cache/zsh_history";
      };

      # Set some aliases
      shellAliases = {
        c = "clear";
        mkdir = "mkdir -vp";
        #rm = "trash";
        #rmr = "trash list | fzf --multi | awk '{$1=$1;print}' | rev | cut -d ' ' -f1 | rev | xargs trash restore --match=exact --force";
        mv = "mv -iv";
        cp = "cp -riv";
        cat = "bat --paging=never --style=plain";
        ls = "eza -a --icons=auto";
        lsa = "ls -all";
        tree = "eza --tree --icons=auto -L 2";
        grep = "rg";

        #Short hands
        mvenv = "python -m venv .venv && source .venv/bin/activate";
        avenv = "source .venv/bin/activate";
        usermount = "sudo mount -o uid=$(id -u $USER),gid=$(id -g $USER),umask=022";

        #Git
        g = "git";
        ga = "git add --patch";
        gs = "git status --short --branch";
        gu = "git pull --rebase";
        gp = "git push";
        gc = "git commit";
        gd = "git diff --output-indicator-new=' ' --output-indicator-old=' '";
        gl = "git log --graph --all --pretty=format:\"%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n\"";

        #Docker
        d = "docker";
        dc = "docker compose";
        dcu = "docker compose up -d";
        dcd = "docker compose down";

        #Nix
        nd = "nix develop -c $SHELL";
        nix-shell = "nix-shell --run zsh";
        llm = "docker compose -f ${config.home.homeDirectory}/Code/AI/LLM/docker-compose.yml";
        #Programs
      }
      // lib.optionalAttrs config.my.isNixOS {
        switch = "sudo nixos-rebuild switch --flake ~dots --no-reexec";
        rebuild = "sudo -v && nix flake update home-flake --flake ~dots && sudo nixos-rebuild switch --flake ~dots --no-reexec --log-format internal-json -v |& nom --json &&  notify-send -a NixOS 'Rebuild complete\!'";
        update = "nix flake update --commit-lock-file -I ~dots && nix flake update -I ~dots/home; notify-send -a NixOS 'System updated\!'";
      };
    };
  };
}
