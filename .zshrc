# The following lines were added by compinstall

# make ^S and ^Q available; who needs this nowadays?
stty -ixon

# add custom completion scripts
fpath=(~/.zsh/completion $fpath)

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

zstyle ':completion:*:*' completer _oldlist _expand _original _complete _match _ignored _correct _approximate _prefix
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

zstyle ':completion:*' group-name ''
zstyle ':completion:*' original true
zstyle ':completion:*' ambiguous true
zstyle ':completion:*' old-matches true
zstyle ':completion:*' match-original both
zstyle ':completion:*' insert-unambiguous true
#zstyle ':completion:*' menu select=1 eval "$(dircolors -b)"
zstyle ':completion:*' menu select=long eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
#zstyle :compinstall filename '/home/jochen/.zshrc'

# http://www.thregr.org/~wavexx/rnd/20141010-zsh_show_ambiguity/
zstyle ':completion:*' show-ambiguity true

autoload -Uz compinit
compinit

function slash-backward-kill-word () {
    local WORDCHARS="${WORDCHARS:s@/@}"
    zle backward-kill-word
}
zle -N slash-backward-kill-word

function slash-vi-backward-word () {
    local WORDCHARS="${WORDCHARS:s@/@}"
    zle vi-backward-word
}
zle -N slash-vi-backward-word

function slash-vi-backward-blank-word () {
    local WORDCHARS="${WORDCHARS:s@/@}"
    zle vi-backward-blank-word
}
zle -N slash-vi-backward-blank-word

function slash-vi-forward-blank-word-end () {
    local WORDCHARS="${WORDCHARS:s@/@}"
    zle vi-forward-blank-word-end
}
zle -N slash-vi-forward-blank-word-end

function slash-vi-forward-blank-word () {
    local WORDCHARS="${WORDCHARS:s@/@}"
    zle vi-forward-blank-word
}
zle -N slash-vi-forward-blank-word

function slash-vi-forward-word-end () {
    local WORDCHARS="${WORDCHARS:s@/@}"
    zle vi-forward-word-end
}
zle -N slash-vi-forward-word-end

function slash-vi-forward-word () {
    local WORDCHARS="${WORDCHARS:s@/@}"
    zle vi-forward-word
}
zle -N slash-vi-forward-word

function accept-search-vi-cmd-mode () {
    zle accept-search
    zle vi-cmd-mode
}
zle -N accept-line-vi-cmd-mode

function accept-line-disown () {
    if ((! $#BUFFER == 0)) {
        local BUFFER="${BUFFER} &!"
    }
    zle accept-line
}
zle -N accept-line-disown

# End of lines added by compinstall
# Lines configured by zsh-newuser-install

autoload -Uz colors; colors

HISTFILE=~/.histfile

# The maximum number of events stored in the internal history list.
HISTSIZE=999999

# maximum number of history events saved in $HISTFILE
SAVEHIST=999999

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
           menucomplete           \
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

bindkey            '^[[Z'      reverse-menu-complete

bindkey -a         'v'         edit-command-line

bindkey -v         '^U'        backward-kill-line
bindkey -a         '^U'        backward-kill-line

bindkey -v         '^[[34~'    slash-backward-kill-word
bindkey -a         '^[[34~'    slash-backward-kill-word

# i can't stand the cursor stopping on last insert position
bindkey -v         '^H'        backward-delete-char
bindkey -a         '^H'        backward-delete-char

# i can't stand the cursor stopping on last insert position
bindkey -v         '^?'        backward-delete-char
bindkey -a         '^?'        backward-delete-char

bindkey -v         '^B'        slash-vi-backward-word
bindkey -a         '^B'        slash-vi-backward-word

bindkey -a         '/'         history-incremental-search-backward
bindkey -v         '^R'        history-incremental-search-backward
bindkey -a         '^R'        history-incremental-search-backward

bindkey -v         '^S'        history-incremental-search-forward
bindkey -a         '^S'        history-incremental-search-forward

bindkey -v         '[35~'    accept-line-disown
bindkey -a         '[35~'    accept-line-disown

bindkey -M isearch '^['        accept-search-vi-cmd-mode

bindkey -a         'B'         slash-vi-backward-blank-word
bindkey -a         'E'         slash-vi-forward-blank-word-end
bindkey -a         'W'         slash-vi-forward-blank-word
bindkey -a         'b'         slash-vi-backward-word
bindkey -a         'e'         slash-vi-forward-word-end
bindkey -a         'w'         slash-vi-forward-word

REPORTTIME=2
TIMEFMT="
  real: %E
  user: %U
  system: %S
  cpu: %P
  mem: %M
"

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

# override fasd default completer set by auto; adds '_original'
zstyle ':completion:*' _original _complete _ignored _fasd_zsh_word_complete_trigger

## don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'

## filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.(o|c~|hi|old|pro|zwc)'

zstyle ':completion:*:*:(zathura|evince):*:*' file-patterns '*.(dvi|pdf|ps)' '*:directories'

## don't complete default users from /etc/passwd
zstyle ':completion:*:*:*:users' ignored-patterns \
    $(cut -d ':' -f 1 /etc/passwd)

## ignore completion functions
zstyle ':completion:*:functions' ignored-patterns '_*'


function TRAPWINCH () {
    for f in $precmd_functions; do
        eval $f
    done
}



source ${HOME}/.profile

# TODO
# history widget:
# read from global histfile for completion
# use a session local histfile (fc -p)
#
# ^O back to original
# wordsplit at '.' and '/'
