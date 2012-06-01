# The following lines were added by compinstall

# make ^S and ^Q available; who needs this nowadays?
stty -ixon

# add custom completion scripts
fpath=(~/.zsh/completion $fpath)

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

zstyle ':completion:*:*' completer _list _oldlist _expand _original _complete _match _ignored _correct _approximate _prefix
zstyle ':completion:*' completions true
zstyle ':completion:*' condition true
zstyle ':completion:*' format '%d'
#zstyle ':completion:corrections:*' format '%d'
zstyle ':completion:*' glob true
zstyle ':completion:*' ignore-parents parent pwd .. directory
#zstyle ':completion:*' list-colors ''
#zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' max-errors 1 numeric
#zstyle ':completion:*' menu select=1
#zstyle ':completion:*' menu select=long
zstyle ':completion:*' preserve-prefix '//[^/]##/'
#zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' substitute true
#zstyle ':completion:*' rehash true

zstyle ':completion:*' original true
zstyle ':completion:*' ambiguous true
zstyle ':completion:*' old-matches true
zstyle ':completion:*' match-original both
zstyle ':completion:*' insert-unambiguous true
#zstyle ':completion:*' menu select=1 eval "$(dircolors -b)"
zstyle ':completion:*' menu select=long eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
#zstyle :compinstall filename '/home/jochen/.zshrc'

autoload -Uz compinit
compinit

# End of lines added by compinstall
# Lines configured by zsh-newuser-install

autoload -Uz colors; colors

HISTFILE=~/.histfile

# history events in internal list
# This number shows up in the prompt with %h
# I want it to stay two digit (more is useless for long gone events)
# Since due to incappendhistory option history might grow by aroung 20% before
# trimming. Therefore 100 - 25% * 100
# 9999/1.2 = 8200
HISTSIZE=8200

# maximum number of history events saved in $HISTFILE
SAVEHIST=8200

# End of lines configured by zsh-newuser-install

# zshoptions(1)
setopt     no_beep                \
                                  \
           transientrprompt       \
                                  \
           interactivecomments    \
                                  \
           nohup                  \
           notify                 \
           autocontinue           \
                                  \
        no_listbeep               \
        no_alwaystoend            \
        no_menucomplete           \
                                  \
           autolist               \
           automenu               \
           listambiguous          \
                                  \
           autonamedirs           \
           autoparamkeys          \
           autoparamslash         \
           autoremoveslash        \
           alwayslastprompt       \
                                  \
        no_recexact               \
           globcomplete           \
           completeinword         \
        no_completealiases        \
                                  \
           listtypes              \
           listpacked             \
           listrowsfirst          \
                                  \
           hashlistall            \
                                  \
        no_match                  \
           kshglob                \
           extendedglob           \
                                  \
           autocd                 \
           autopushd              \
           cdablevars             \
           chasedots              \
           chaselinks             \
                                  \
           appendhistory          \
           incappendhistory       \
           histnostore            \
           histignorealldups      \
           histsavenodups         \
           histreduceblanks       \
           histverify


#PROMPT='[%h %~%(!.#.$)] '
#RPROMPT='[%n@%m, %D{%a %b %d, %H:%M] '
#RPROMPT='[%n@%m, %D{%A, %d. %B %Y %H:%M}]'

autoload -U edit-command-line
zle -N edit-command-line

# sets viins as default and link it to main
bindkey -v
bindkey     "^[[Z"      reverse-menu-complete
bindkey -a  v           edit-command-line

bindkey -v  '^U'        backward-kill-line
bindkey -a  '^U'        backward-kill-line

bindkey -v  '^[[33~'    backward-kill-word
bindkey -a  '^[[33~'    backward-kill-word

bindkey -v  '^R'        history-incremental-search-backward
bindkey -a  '^R'        history-incremental-search-backward

bindkey -v  '^S'        history-incremental-search-forward
bindkey -a  '^S'        history-incremental-search-forward


REPORTTIME=2
TIMEFMT="
  real: %E
  user: %U
  system: %S
  cpu: %P
  mem: %M
"

# named directories
hash -d doc=${HOME}/doc               \
        pdf=${HOME}/pdf               \
        src=${HOME}/src               \
        tex=${HOME}/tex               \
        tmp=${HOME}/tmp               \
        usr=${HOME}/.local/usr        \
        proj=${HOME}/proj             \
        vim=${HOME}/.vim              \
        xmonad=${HOME}/.xmonad        \
        dotfiles=${HOME}/dotfiles     \
                                      \
        media=/data/media             \
        music=/data/media/music       \
        movie=/data/media/movie       \
        img=/data/media/img           \
        pic=/data/media/img/pic       \
        jdl=/data/media/jdl/downloads

for d in ${HOME}/proj/*(/); {
    hash -d ${d:t}=${d}
}

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

for prompt in ~/.zsh/prompt/*.zsh; do source $prompt; done

if [[ -x $(which fasd) ]] {
    eval "$(fasd --init auto)"
}

source ${HOME}/.profile

# history widget:
# read from global histfile for completion
# use a session local histfile (fc -p)
