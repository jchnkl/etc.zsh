# The following lines were added by compinstall

zstyle ':completion:*' completer _list _oldlist _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' max-errors 1 numeric
zstyle :compinstall filename '/home/jochen/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt extendedglob
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install

PROMPT='[%~%(!.#.$)] '
RPROMPT='[%n@%m, %D{%a %b %d, %H:%M] '

autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

source ${HOME}/.profile
