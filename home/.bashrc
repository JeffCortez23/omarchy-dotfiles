# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

. "$HOME/.local/share/../bin/env"

# Alias para reactivar DLCs de Los Sims 4
alias fixsims='(cd "/home/elyefris/Downloads/EA DLC Unlocker ES v3.2/EA DLC Unlocker v3.2" && ./activar_dlcs.sh)'

alias dcam="droidcam > /dev/null 2>&1 & sleep 5 && mpv av://v4l2:/dev/video2 --profile=low-latency --untimed &"
export PATH=$HOME/bin:$PATH
export PATH=$HOME/bin:$PATH
