{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.voxtype;
in
{
  options.modules.voxtype = {
    enable = mkEnableOption "voxtype";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.wtype ];

    programs.voxtype = {
      enable = true;
      package = pkgs.voxtype-vulkan;
      model.name = "large-v3-turbo";
      service.enable = true;
      #
      #     # All config options go in settings (converted to config.toml)
      settings = {
        hotkey.enabled = false; # Use compositor keybindings instead
        hotkey.key = "RIGHTALT";
        output = {
          mode = "type";
          fallback_to_clipboard = true;
          type_delay_ms = 0;
          pre_type_delay_ms = 0;
          auto_submit = false;
          shift_enter_newlines = true;
          notification = {
            on_recording_start = true;
            on_recording_stop = false;
            on_transcription = true;
          };
        };
        audio = {
          device = "default";
          sample_rate = 16000;
          max_duration_secs = 60;
        };
        whisper = {
          mode = "remote";
          remote_endpoint = "http://pc:8080";
          translate = false;
          on_demand_loading = false;
          model = "large-v3-turbo";
          language = [
            "en"
            "nl"
          ];
        };
        profiles = {
          command-line = {
            initial_prompt = "Technical description of linux command, no caps or punctuation";
            text = {
              spoken_punctuation = true;
            };
          };
          security = {
            initial_prompt = "Technical security and programming discussion with code terms";
          };
          nl = {
            initial_prompt = "Een bericht in het nederlands, do not translate";
          };
        };
      };
    };
  };
}
