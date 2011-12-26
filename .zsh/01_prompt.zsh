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
local _LONGDATE="%D{%A, %d. %B %Y %H:%M}";
local _SHRTDATE="%D{%a, %d. %b %y %H:%M}";
local _VCS="${vcs_info_msg_0_}";


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
pelems+=(${_LONGDATE}	"${_EMPH}%D{%A}%f, ${_NCOLO}%D{%d. %B %Y} ${_EMPH}%D{%H:%M}%f")
pelems+=(${_SHRTDATE}	"${_EMPH}%D{%a}%f, ${_NCOLO}%D{%d. %b %y} ${_EMPH}%D{%H:%M}%f")
pelems+=(${_VCS}	"${vcs_info_msg_0_}")


autoload zsh/terminfo;
if [[ "$terminfo[colors]" -ge 8 ]]; then _FANCY=true; else _FANCY=false; fi

# do the heavy lifting only every $PERIOD
function updateWeather() {
    local WEATHERFILE=${HOME}/.zsh/weather
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
    local _PCOND="%{%${#_COND}G${_COND}%}"
    local _PSKYC="%{%${#_SKYC}G${_SKYC}%}"

    pelems+=(${_PTEMP} "%{$fg[${TCOLOR}]%}%{%${#_TEMP}G${_TEMP}%}%{$fg[default]%}${_NCOLO}°C%f")
    pelems+=(${_PWIND} "${_NCOLO}%{%${#_WIND}G${_WIND}%}kmh%f")
    pelems+=(${_PCOND} "${_NCOLO}%{%${#_COND}G${_COND}%}%f")
    pelems+=(${_PSKYC} "${_NCOLO}%{%${#_SKYC}G${_SKYC}%}%f")

    _SHRTWEATHER=${_PTEMP}
    pelems[${_SHRTWEATHER}]=${pelems[${_PTEMP}]}

    local _WP
    _WP=(${_PTEMP} ${_COMMA} ${_WS} ${_PWIND} ${_COMMA} ${_WS})
    if [ -z "${_COND}" ]; then
        _WP+=(${_PSKYC})
    else
        _WP+=(${_PCOND} ${_COMMA} ${_WS} ${_PSKYC})
    fi

    _LONGWEATHER=
    local _CLONGWEATHR
    for e in ${_WP}; do
        _LONGWEATHER+=${e}
        _CLONGWEATHR+=${(v)pelems[${e}]}
    done
    pelems+=(${_LONGWEATHER} ${_CLONGWEATHR})

}

periodic_functions+=(updateWeather)

[ -z "${_SHRTWEATHER}" -o -z "${_LONGWEATHER}" ] && updateWeather


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


local _SHOMEP _LHOMEP
if [ -z "${SSH_CONNECTION}" ]; then
    _LHOMEP+=(${_LONGWEATHER} ${_WS} ${_SEP} ${_WS} ${_LONGDATE})
else
    _LHOMEP+=(${_LOGIN} ${_HOSTSEP} ${_HOST} ${_WS} ${_SEP} ${_WS} ${_LONGDATE})
fi

if [ -z "${SSH_CONNECTION}" ]; then
    _SHOMEP+=(${_PWD} ${_WS} ${_SEP} ${_WS} ${_SHRTWEATHER} ${_WS} ${_SEP} ${_WS} ${_SHRTDATE})
else
    _SHOMEP+=(${_PWD} ${_WS} ${_SEP} ${_WS} ${_LOGIN} ${_HOSTSEP} ${_HOST} ${_WS} ${_SEP} ${_WS} ${_SHRTDATE})
fi


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
