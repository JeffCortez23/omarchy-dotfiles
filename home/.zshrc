# =============================================================================
# 1. MIGRACIÓN DE BASH (Carga tus atajos y variables antiguas)
# =============================================================================
if [ -f ~/.zsh_aliases ]; then source ~/.zsh_aliases; fi
if [ -f ~/.zsh_exports ]; then source ~/.zsh_exports; fi

# =============================================================================
# 2. CONFIGURACIÓN BASE DE ZSH
# =============================================================================
# Historial de comandos
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory      # Añadir al historial en vez de sobrescribir
setopt sharehistory       # Compartir historial entre terminales abiertas
setopt histignorealldups  # No guardar comandos duplicados

# Autocompletado avanzado
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select # Menú navegable con flechas

# =============================================================================
# 3. DISEÑO VISUAL (Prompt minimalista)
# =============================================================================
# %F{cyan} da el color, %~ muestra la ruta actual, %f resetea el color
PROMPT='%F{cyan}%~%f ❯ '

# =============================================================================
# 4. PLUGINS (Rutas oficiales de Arch Linux)
# =============================================================================
# Sugerencias en gris mientras escribes (presiona flecha derecha para aceptar)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Resaltado de sintaxis (verde si el comando existe, rojo si no)
# ¡IMPORTANTE! Este plugin siempre debe ser la última línea del archivo
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Load Angular CLI autocompletion.
source <(ng completion script)

# Added by vibez installer
export PATH="${HOME}/.local/bin:${PATH}"

# --- Atajos para Proyectar ---
alias proyectar-on='sudo systemctl stop iwd && sudo systemctl start NetworkManager && echo "Epson Mode: ON (NetworkManager activo)"'
alias proyectar-off='sudo systemctl stop NetworkManager && sudo systemctl start iwd && echo "Epson Mode: OFF (iwd/Omarchy activo)"'
