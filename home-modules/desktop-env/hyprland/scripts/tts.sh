#! /usr/bin/env nix-shell
#! nix-shell -i bash piper-tts -p bash

# Path to your piper-tts voice model (.onnx); replace /home/<you> with your home directory
MODEL="/home/<you>/path/to/piper-voice.onnx"
SPEED=0.7
# Grab the current selection
# This works for Wayland (wl-clipboard) and X11 (xsel)
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    TEXT=$(wl-paste -p)
else
    TEXT=$(xsel -o)
fi

# Exit if selection is empty
if [ -z "$TEXT" ]; then
    exit 0
fi

# Kill any previous instances so they don't talk over each other
pkill -f piper
pkill -f pw-play

# Run your specific command
echo "$TEXT" | piper --model "$MODEL" --length_scale "$SPEED" --noise_scale 0 --noise_w 0 --sentence_silence 0.1 --output_raw |
    pw-play --rate 22050 --format s16 --volume 1 --channels 1 -a -
