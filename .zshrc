# The following lines were added by compinstall

# add custom completion scripts
fpath=(~/.zsh/completion $fpath)

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

zstyle ':completion:*' completer _oldlist _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' completions 1
zstyle ':completion:*' condition 1
zstyle ':completion:*' format '%d'
zstyle ':completion:*' glob 1
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' max-errors 1 numeric
zstyle ':completion:*' menu select=long
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' substitute 1
zstyle :compinstall filename '/home/jochen/.zshrc'

autoload -Uz compinit
compinit

# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=9999
SAVEHIST=9999
bindkey -v
# End of lines configured by zsh-newuser-install

# zshoptions(1)
setopt appendhistory extendedglob nomatch notify
setopt kshglob autocd autopushd cdablevars chasedots chaselinks histnostore
setopt histignorealldups histsavenodups histreduceblanks histverify
setopt incappendhistory transientrprompt nohup
unsetopt beep

PROMPT='[%h %~%(!.#.$)] '
RPROMPT='[%n@%m, %D{%a %b %d, %H:%M] '

autoload -U edit-command-line
zle -N edit-command-line

bindkey -M vicmd v edit-command-line
bindkey "^[[Z" reverse-menu-complete

TIMEFMT="
  real: %E
  user: %U
  system: %S
  cpu: %P
  mem: %M
"

# named directories
doc=${HOME}/doc
pdf=${HOME}/pdf
src=${HOME}/src
tex=${HOME}/tex
tmp=${HOME}/tmp
usr=${HOME}/usr
work=${HOME}/work
media=/data/media
music=/data/media/music
movie=/data/media/movie
img=/data/media/img
pic=/data/media/img/pic
jdl=/data/media/jdl/downloads

# open files with programs matching the extension
function setsuf() {
  PROG=${1}
  shift
  for i in ${*}; do
    alias -s ${i}=${PROG};
    alias -s ${(U)i}=${PROG};
  done
}

MOVSUF=(mkv mpg avi)
PDFSUF=(pdf dvi ps)
IMGSUF=(jpg nef png tif)
TXTSUF=(tex txt x10 hs h hpp c cc cpp java)

setsuf mplayer ${MOVSUF}

if [ ${DISPLAY} ]; then
  setsuf gvim ${TXTSUF}
  setsuf evince ${PDFSUF}
  setsuf geeqie ${IMGSUF}
else
  setsuf vim ${TXTSUF}
fi

r() {
  local f
  f=(~/.zsh/completion/*(.))
  unfunction $f:t 2> /dev/null
  autoload -U $f:t
}

source ${HOME}/.profile
