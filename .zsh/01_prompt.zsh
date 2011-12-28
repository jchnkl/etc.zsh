# global variables: pelems _LONGWEATHER _SHRTWEATHER _SHOMEP _LHOMEP

PERIOD=600

local _NCOLO="%14F" # 66
local _SCOLO="%59F" # 237 # 23 # 240
local _ECOLO="%3F"
local _EMPH="%251F"

local _WS=" ";
local _SEP="|";
local _COMMA=",";
local _LBRKT="[";
local _RBRKT="]";
local _HOSTSEP="@";
local _PCHAR="%(!.#.$)";
local _HIST="!%h";
local _PWD="%~";
local _LOGIN="%n";
local _HOST="%2m";
local _LONGDATE="%D{%A, %d. %B %Y | %H:%M}";
local _SHRTDATE="%D{%a, %d. %b %y | %H:%M}";
local _VCS="${vcs_info_msg_0_}";


# global array
typeset -A pelems
pelems+=(${_WS}		"${_WS}")
pelems+=(${_SEP}	"${_SCOLO}${_SEP}%f")
pelems+=(${_COMMA}	"${_SCOLO}${_COMMA}%f")
pelems+=(${_LBRKT}	"%0K${_SCOLO}${_LBRKT}%f")
pelems+=(${_RBRKT}	"${_SCOLO}${_RBRKT}%f%k")
pelems+=(${_HOSTSEP}	"${_SCOLO}${_HOSTSEP}%f")
pelems+=(${_PCHAR}	"%(!.%1F#%f.%4F$%f)")
pelems+=(${_HIST}	"${_NCOLO}!${_EMPH}%h%f")
pelems+=(${_PWD}	"%4F${_PWD}%f")
pelems+=(${_LOGIN}	"${_ECOLO}${_LOGIN}%f")
pelems+=(${_HOST}	"${_ECOLO}${_HOST}%f")
pelems+=(${_LONGDATE}	"${_EMPH}%D{%A}%f, ${_EMPH}%D{%d}%f${_NCOLO}%D{. %B %Y} ${_SCOLO}${_SEP}%f ${_EMPH}%D{%H:%M}%f")
pelems+=(${_SHRTDATE}	"${_EMPH}%D{%a}%f, ${_EMPH}%D{%d}%f${_NCOLO}%D{. %b %y} ${_SCOLO}${_SEP}%f ${_EMPH}%D{%H:%M}%f")
pelems+=(${_VCS}	"${vcs_info_msg_0_}")


# do the heavy lifting only every $PERIOD
function updateWeather() {
    local WEATHERFILE=${HOME}/.zsh/weather
    if [ ! -r ${WEATHERFILE} ]; then
        return
    fi
    local _TEMP="$(grep "Temperature:" ${WEATHERFILE} | cut -d ' ' -f 2)"
    local _WIND="$(grep "Wind:" ${WEATHERFILE} | cut -d ' ' -f 4,8)"
    local _COND="$(grep "Weather:" ${WEATHERFILE} | cut -d ' ' -f 2-)"
    local _SKYC="$(grep "Sky conditions:" ${WEATHERFILE} | cut -d ' ' -f 3-)"

    local TCOLOR
    if [ ${_TEMP} -le 4 ]; then TCOLOR=blue;
    elif [ ${_TEMP} -le 10 ]; then TCOLOR=cyan;
    elif [ ${_TEMP} -le 16 ]; then TCOLOR=green;
    elif [ ${_TEMP} -le 22 ]; then TCOLOR=yellow;
    elif [ ${_TEMP} -le 28 ]; then TCOLOR=magenta;
    else TCOLOR=red;
    fi

    local _PTEMP="%{%${#_TEMP}G${_TEMP}%}°C"
    local _PWIND="%{%${#_WIND}G${_WIND}%}kmh"

    pelems+=(${_PTEMP} "%{$fg[${TCOLOR}]%}%{%${#_TEMP}G${_TEMP}%}%{$fg[default]%}${_NCOLO}°C%f")
    pelems+=(${_PWIND} "${_NCOLO}%{%${#_WIND}G${_WIND}%}kmh%f")

    # global variable
    _SHRTWEATHER=${_PTEMP}
    pelems[${_SHRTWEATHER}]=${pelems[${_PTEMP}]}

    local _WP= _PSEP=${_COMMA}'\0'${_WS}
    concatWith ${_PSEP} ${_PTEMP} ${_PWIND}; _WP=($reply)

    # Conditions are not always present
    if [ -n "${_COND}" ]; then
        local _PCOND
        for c1 c2 in ${(s:; :)_COND}; do
            if [ -n "${c2}" ]; then
                _PCOND+=("%{%${#c1}G${c1}%}, %{%${#c2}G${c2}%")
                pelems+=(${_PCOND} "${_NCOLO}%{%${#c1}G${c1}%}${_SCOLO}, ${_NCOLO}%{%${#c2}G${c2}%}")
            else
                _PCOND+=("%{%${#c1}G${c1}%}")
                pelems+=(${_PCOND} "${_NCOLO}%{%${#c1}G${c1}%}${_SCOLO}")
            fi
        done

        _WP+=(${(s:\0:)_PSEP} ${_PCOND})
    fi

    # Sky Conditions is not always present
    if [ -n "${_SKYC}" ]; then
        local _PSKYC="%{%${#_SKYC}G${_SKYC}%}"
        pelems+=(${_PSKYC} "${_NCOLO}%{%${#_SKYC}G${_SKYC}%}%f")
        _WP+=(${(s:\0:)_PSEP} ${_PSKYC})
    fi

    # global variable
    _LONGWEATHER=
    local _CLONGWEATHR
    for e in ${_WP}; do
        _LONGWEATHER+=${e}
        _CLONGWEATHR+=${(v)pelems[${e}]}
    done
    pelems+=(${_LONGWEATHER} ${_CLONGWEATHR})

}


function updatePrompt() {
    # global variables
    _SHOMEP= _LHOMEP=
    local _PSEP=${_WS}'\0'${_SEP}'\0'${_WS}
    if [ -z "${SSH_CONNECTION}" ]; then
        concatWith ${_PSEP} ${_LONGWEATHER} ${_LONGDATE}; _LHOMEP+=(${reply})
        concatWith ${_PSEP} ${_PWD} ${_SHRTWEATHER} ${_SHRTDATE}; _SHOMEP+=(${reply})
    else
        local _LGNATHST=${_LOGIN}'\0'${_HOSTSEP}'\0'${_HOST}
        concatWith ${_PSEP} ${_LGNATHST} ${_LONGDATE}; _LHOMEP+=(${reply})
        concatWith ${_PSEP} ${_PWD} ${_LGNATHST} ${_SHRTDATE}; _SHOMEP+=(${reply})
    fi
}


# splitting of arguments is based on '\0'
function concatWith() {
    local _concatWithSep=${1}; shift;

    reply=(${(s:\0:)1}); shift;
    while [ -n "${1}" ]; do
        reply+=(${(s:\0:)_concatWithSep} ${(s:\0:)1}); shift;
    done
}


function precmd() {

    vcs_info

    # if vcs -> vcs/path anstatt wetter/zeit

    local _RP
    _RP=(${_LBRKT})

    if [ "${PWD}" = "${HOME}" ]; then
        _RP+=(${_LHOMEP})
    else
        _RP+=(${_SHOMEP})
    fi

    _RP+=(${_RBRKT})

    RPROMPT=
    for e in ${_RP}; do
        if ${_FANCY}; then
            RPROMPT+=${(v)pelems[${e}]}
        else
            RPROMPT+=${(k)pelems[${e}]}
        fi
    done

}


autoload zsh/terminfo;
if [[ "$terminfo[colors]" -ge 8 ]]; then _FANCY=true; else _FANCY=false; fi

periodic_functions+=(updateWeather updatePrompt)

if [ -z "${_SHRTWEATHER}" -o -z "${_LONGWEATHER}" ]; then
    updateWeather
    updatePrompt
fi


local _BOTPROMPT=
for e in ${_LBRKT} ${_HIST} ${_WS} ${_PCHAR} ${_RBRKT} ${_WS}; do
    if ${_FANCY}; then
        _BOTPROMPT+=${(v)pelems[${e}]}
    else
        _BOTPROMPT+=${(k)pelems[${e}]}
    fi
done

PROMPT="
${_BOTPROMPT}"
