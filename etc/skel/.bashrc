# Proposed skeleton for linux os's using a bash prompt.
# Every other configuration should be done in $SHARED_HDD/$USER/.bashrc


# load local environment variables
[[ -f "$HOME/.bash_env" ]] && . "$HOME/.bash_env"
# load shared environment variables
[[ -f "$SHARED_FS/$USER/.bash_env" ]] && . "$SHARED_FS/$USER/.bash_env"
# load shared bashrc (and other stuff)
[[ -f "$HOMEPATH/.bashrc" ]] && . "$HOMEPATH/.bashrc"
# load local bash_aliases
[[ -f "$HOME/.bash_aliases" ]] && . "$HOME/.bash_aliases"
# load local custom functions
[[ -f "$HOME/.bash_functions" ]] && . "$HOME/.bash_functions"
