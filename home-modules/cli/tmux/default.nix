{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.tmux;
in {
  options.modules.tmux = {enable = mkEnableOption "tmux";};
  config = mkIf cfg.enable (let
    c = config.lib.stylix.colors;
    bg = "#${c.base00}";
    bgAlt = "#${c.base01}";
    sel = "#${c.base02}";
    fgDim = "#${c.base03}";
    fg = "#${c.base05}";
    blue = "#${c.base0D}";
    green = "#${c.base0B}";
    yellow = "#${c.base0A}";
    red = "#${c.base08}";
  in {
    programs.tmux = {
      enable = true;
      clock24 = true;
      shell = "${pkgs.zsh}/bin/zsh";
      baseIndex = 1;
      escapeTime = 0;
      mouse = true;
      keyMode = "vi";
      prefix = "C-Space";
      plugins = with pkgs; [
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.vim-tmux-navigator
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-boot 'on'
            set -g @continuum-save-interval '10'
          '';
        }
      ];

      extraConfig = ''
        # ── Colors ───────────────────────────────────────────────────────────
        set -g status-style             "bg=${bgAlt} fg=${fg}"
        set -g pane-border-style        "fg=${sel}"
        set -g pane-active-border-style "fg=${blue}"
        set -g message-style            "fg=${yellow} bg=${bgAlt} bold"
        set -g message-command-style    "fg=${yellow} bg=${bgAlt}"

        # ── Status bar ────────────────────────────────────────────────────────
        set -g status-interval    5
        set -g status-left-length 30
        set -g status-right-length 80

        # Left: session name — pill turns red while prefix is held
        set -g status-left "#[fg=${bg},bold]#{?client_prefix,#[bg=${red}],#[bg=${blue}]}  #{session_name} #{?client_prefix,#[fg=${red}],#[fg=${blue}]}#[bg=${bgAlt},nobold]"

        # Windows: inactive dim, current highlighted with powerline bookends
        set -g window-status-separator      ""
        set -g window-status-format         "#[fg=${fgDim},bg=${bgAlt}] #I  #W "
        set -g window-status-current-format "#[fg=${bgAlt},bg=${sel}]#[fg=${blue},bg=${sel},bold] #I  #W #[fg=${sel},bg=${bgAlt},nobold]"

        # Right: clock with powerline arrow
        set -g status-right "#[fg=${blue},bg=${bgAlt}]#[fg=${bg},bg=${blue},bold]  %H:%M "


        # ── 256-colors ────────────────────────────────────────────────────────
        set -g default-terminal 'screen-256color'
        set -ag terminal-overrides ',xterm-256color*:RGB'


        # ── Keybindings ───────────────────────────────────────────────────────
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        bind | split-window -h
        bind _ split-window -v
        unbind '"'
        unbind %

        bind -n M-Left  select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up    select-pane -U
        bind -n M-Down  select-pane -D

        bind -n S-Left  previous-window
        bind -n S-Right next-window
        bind -n M-H     previous-window
        bind -n M-L     next-window
      '';
    };
  });
}
