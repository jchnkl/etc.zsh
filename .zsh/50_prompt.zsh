# TODO
# updateWeather: check age of file and (don't) update

local PERIOD=600
local WEATHEROK=0
local BATOK=0
# 1.618 ^= golden ratio
local RPMAX=$(((${COLUMNS}*1000)/1618))


local _NCOLO="%14F" # 66
local _SCOLO="%59F" # 237 # 23 # 240
local _ECOLO="%3F"
local _EMPH="%251F"

local _WS=" ";
local _SEP="${(#)${:-166}}";
local _COMMA=",";
local _LBRKT="[";
local _RBRKT="]";
local _HOSTSEP="@";
local _PWD="%~";
local _LOGIN="%n";
local _HOST="%2m";

typeset -A sprompt
sprompt+=( " "     "${_WS}"                     )
sprompt+=( " | "   "${_WS}${_SEP}${_WS}"        )
sprompt+=( ","      "${_COMMA}"                 )
sprompt+=( "["      "${_LBRKT}"                 )
sprompt+=( "]"      "${_RBRKT}"                 )
sprompt+=( "@"      "${_HOSTSEP}"               )
sprompt+=( "#"      "%(!.#.$)"                  )
sprompt+=( "pwd"    "${_PWD}"                   )
sprompt+=( "name"   "${_LOGIN}"                 )
sprompt+=( "host"   "${_HOST}"                  )
sprompt+=( "time"   "%D{%H:%M}"                 )
sprompt+=( "ldate"  "%D{%A}, %D{%d}%D{. %B %Y}" )
sprompt+=( "sdate"  "%D{%a}, %D{%d}%D{. %b %y}" )

typeset -A cprompt
cprompt+=( " "     "${_WS}"                                                  )
cprompt+=( " | "    "${_SCOLO}${_WS}${_SEP}${_WS}%f"                         )
cprompt+=( ","      "${_SCOLO}${_COMMA}%f"                                   )
cprompt+=( "["      "%0K${_SCOLO}${_LBRKT}%f"                                )
cprompt+=( "]"      "${_SCOLO}${_RBRKT}%f%k"                                 )
cprompt+=( "@"      "${_SCOLO}${_HOSTSEP}%f"                                 )
cprompt+=( "#"      "%(!.%1F#%f.%4F$%f)"                                     )
cprompt+=( "pwd"    "%4F${_PWD}%f"                                           )
cprompt+=( "name"   "${_ECOLO}${_LOGIN}%f"                                   )
cprompt+=( "host"   "${_ECOLO}${_HOST}%f"                                    )
cprompt+=( "time"   "${_EMPH}%D{%H:%M}%f"                                    )
cprompt+=( "ldate"  "${_EMPH}%D{%A}%f, ${_EMPH}%D{%d}%f${_NCOLO}%D{. %B %Y}" )
cprompt+=( "sdate"  "${_EMPH}%D{%a}%f, ${_EMPH}%D{%d}%f${_NCOLO}%D{. %b %y}" )

function constructPrompt () {

    local _elems= _prompt=
    typeset -A _elems
    _elems=(${(Pkv)1})
    shift

    for e in $@; do
        _prompt+=${_elems[$e]}
    done

    echo ${_prompt}

}

function mkHistPrompt () {
    local HEVENTS=${(l.4..0.)$((${HISTCMD} % 10000))}
    cprompt+=( "!" "${_NCOLO}!${_EMPH}${HEVENTS}%f" )
    sprompt+=( "!" "!${HEVENTS}" )
}

function mkNormalPrompt () {
    local _lvl=$1; shift

    typeset -a _prmpt

    function dirPrompt () {
        if [ ! ${PWD} = ${HOME} ]; then
            resp=("pwd" " | ")
            echo ${(pj:\0:)resp}
        fi
    }

    function weatherPrompt () {
        if [ ${WEATHEROK} -eq 1 ]; then
            resp=("$1" " | ")
            echo ${(pj:\0:)resp}
        fi
    }

    function batPrompt () {
        if [ ${BATOK} -eq 1 ]; then
            resp=(" | " "$1")
            echo ${(pj:\0:)resp}
        fi
    }

    case ${_lvl} in
        0)
            _prmpt=( "[" "${(ps:\0:)$(dirPrompt)}" \
                     "${(ps:\0:)$(weatherPrompt "lweather")}" \
                     "ldate" " | " "time" \
                     "${(ps:\0:)$(batPrompt "lbat")}" \
                     "]" \
                   )
        ;;

        1)
            _prmpt=( "[" "${(ps:\0:)$(dirPrompt)}" \
                     "${(ps:\0:)$(weatherPrompt "sweather")}" \
                     "ldate" " | " "time" \
                     "${(ps:\0:)$(batPrompt "lbat")}" \
                     "]" \
                   )
        ;;

        2)
            _prmpt=( "[" "${(ps:\0:)$(dirPrompt)}" \
                     "${(ps:\0:)$(weatherPrompt "sweather")}" \
                     "sdate" " | " "time" \
                     "${(ps:\0:)$(batPrompt "lbat")}" \
                     "]" \
                   )
        ;;

        3)
            _prmpt=( "[" "${(ps:\0:)$(dirPrompt)}" \
                     "sdate" " | " "time" \
                     "${(ps:\0:)$(batPrompt "lbat")}" \
                     "]" \
                   )
        ;;

        4)
            _prmpt=( "[" "${(ps:\0:)$(dirPrompt)}" \
                     "sdate" " | " "time" \
                     "${(ps:\0:)$(batPrompt "sbat")}" \
                     "]" \
                   )
        ;;

        5)
            _prmpt=( "[" "${(ps:\0:)$(dirPrompt)}" \
                     "time" \
                     "${(ps:\0:)$(batPrompt "sbat")}" \
                     "]" \
                   )
        ;;

        6)
            _prmpt=( "[" "pwd" \
                     "${(ps:\0:)$(batPrompt "sbat")}" \
                     "]" \
                   )
        ;;

        7)
            _prmpt=( "[" "pwd" "]" )
        ;;

        8)
            _prmpt=( "[" "tpwd" "]" )
        ;;
        *) echo ;;
    esac

    constructPrompt $1 ${(v)_prmpt}

}

function mkSSHPrompt () {
    local _lvl=$1; shift

    typeset -a _prmpt

    function dirPrompt () {
        if [ ! ${PWD} = ${HOME} ]; then
            resp=("pwd" " | ")
            echo ${(pj:\0:)resp}
        fi
    }

    case ${_lvl} in
        0)
            _prmpt=( "[" "${(ps:\0:)$(dirPrompt)}" \
                     "name" "@" "host" " | " "ldate" " | " "time" \
                     "]" \
                   )
        ;;

        1)
            _prmpt=( "[" "${(ps:\0:)$(dirPrompt)}" \
                     "name" "@" "host" " | " "sdate" " | " "time" \
                     "]" \
                   )
        ;;

        2)
            _prmpt=( "[" "${(ps:\0:)$(dirPrompt)}" \
                     "name" "@" "host" " | " "time" \
                     "]" \
                   )
        ;;

        3)
            _prmpt=( "[" "${(ps:\0:)$(dirPrompt)}" \
                     "name" "@" "host" \
                     "]" \
                   )

        ;;

        4)
            _prmpt=( "[" "pwd" "]" )

        ;;

        5)
            _prmpt=( "[" "tpwd" "]" )

        ;;
        *) echo ;;
    esac

    constructPrompt $1 ${(v)_prmpt}
}

function mkRPrompt () {
    if [ -z "${SSH_CONNECTION}" ]; then
        mkNormalPrompt $@
    else
        mkSSHPrompt $@
    fi
}

function mkTruncatedRPrompt () {

    local _pelems=$1 _c=0 _tmp=

    function tmpprompt () { mkRPrompt ${_c} sprompt }

    _tmp=$(tmpprompt ${_c})

    while [ ${#${(%)_tmp}} -gt ${RPMAX} ]; do
        _c=$((${_c} + 1))
        _tmp=$(tmpprompt ${_c})
    done

    mkRPrompt ${_c} $_pelems

}

function weatherUpdate () {
    local _weather=
    typeset -a _weather
    _weather=( ${(ps:\0:)"$(updateWeather)"} )

    if [ -n "${_weather[1]}" -a -n "${_weather[2]}" -a -n "${_weather[3]}" -a -n "${_weather[4]}" ]; then
        sprompt+=( "sweather" "${_weather[1]}" )
        cprompt+=( "sweather" "${_weather[2]}" )
        sprompt+=( "lweather" "${_weather[3]}" )
        cprompt+=( "lweather" "${_weather[4]}" )
        WEATHEROK=1
    else
        WEATHEROK=0
    fi
}

function vcsUpdate () {

    local sblen= trunc=

    vcs_info

    if [ -n "${vcs_info_msg_0_}" ]; then

        sblen=$(((${RPMAX}-${#vcs_info_msg_3_})/2 - 1))

        if [ ${#vcs_info_msg_2_} -ge ${sblen} ]; then
            trunc="%${sblen}>».>${vcs_info_msg_2_}%>>%${sblen}<.«<${vcs_info_msg_2_}%<<"
        else
            trunc=${vcs_info_msg_2_}
        fi

        sprompt+=( "pwd" "${vcs_info_msg_0_}${trunc}"      )
        cprompt+=( "pwd" "${vcs_info_msg_1_}%4F${trunc}%f" )

    else

        sprompt+=( "pwd" "${_PWD}"      )
        cprompt+=( "pwd" "%4F${_PWD}%f" )

    fi

}

function batteryUpdate () {
    local _bprompt=
    typeset -a _bprompt
    _bprompt=( ${(ps:\0:)"$(updateBattery)"} )

    if [ -n "${_bprompt}" ]; then
        BATOK=1;

        sprompt+=( "sbat" "${_bprompt[1]}" )
        cprompt+=( "sbat" "${_bprompt[2]}" )
        sprompt+=( "lbat" "${_bprompt[3]}" )
        cprompt+=( "lbat" "${_bprompt[4]}" )

    else
        BATOK=0;
    fi
}

function rpromptUpdate () {

    local _TRUNLEN=$((${RPMAX}/2 - 1))
    local _CURPATH=${(%)${:-%~}}

    sprompt+=( "tpwd" "%${_TRUNLEN}>».>%${_CURPATH}%>>%${_TRUNLEN}<.»<%${_CURPATH}%<<" )
    cprompt+=( "tpwd" "%4F%${_TRUNLEN}>».>%${_CURPATH}%>>%${_TRUNLEN}<.«<%${_CURPATH}%<<%f" )

    RPROMPT=$(mkTruncatedRPrompt ${_pelems} ${RPMAX} )

}

function promptUpdate () {

    PROMPT="
$(constructPrompt ${_pelems} "[" "!" " " "#" "]" " " )"

}

function rpmaxUpdate () {
    RPMAX=$(((${COLUMNS}*1000)/1618))
}

autoload zsh/terminfo;

if [[ "$terminfo[colors]" -ge 8 ]]; then
    _pelems=cprompt
else
    _pelems=sprompt
fi

# initial update
weatherUpdate

periodic_functions+=( weatherUpdate )
precmd_functions+=(   rpmaxUpdate mkHistPrompt batteryUpdate vcsUpdate \
                      rpromptUpdate promptUpdate \
                  )
