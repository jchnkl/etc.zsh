# global variables: pelems _LONGWEATHER _SHRTWEATHER _SHOMEP _LHOMEP

PERIOD=600

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
local _PCHAR="%(!.#.$)";
local _HIST="!%h";
local _PWD="%~";
local _LOGIN="%n";
local _HOST="%2m";
local _TIME="%D{%H:%M}";
local _LONGDATE="%D{%A, %d. %B %Y}";
local _SHRTDATE="%D{%a, %d. %b %y}";
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
pelems+=(${_TIME}	"${_EMPH}%D{%H:%M}%f")
pelems+=(${_LONGDATE}	"${_EMPH}%D{%A}%f, ${_EMPH}%D{%d}%f${_NCOLO}%D{. %B %Y}")
pelems+=(${_SHRTDATE}	"${_EMPH}%D{%a}%f, ${_EMPH}%D{%d}%f${_NCOLO}%D{. %b %y}")
pelems+=(${_VCS}	"${vcs_info_msg_0_}")


# do the heavy lifting only every $PERIOD
function updateWeather() {
    local WEATHERFILE=${HOME}/.zsh/weather
    if [ ! -s ${WEATHERFILE} ]; then
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
        local _PCOND= _CCOND=
        for c in ${(s:\0:S)${_COND}//(; |, )/'\0'}; do # split at commas and semicolons
          _PCOND+=(%{%${#c}G${c}%})
          _CCOND+=(${_NCOLO}%{%${#c}G${c}%}${_SCOLO})
        done

        # join with ', '; remove a head comma (, ) if necessary (#)
        pelems+=(${${(j:, :)_PCOND}/#, /} ${${(j:, :)_CCOND}/#, /})
        _WP+=(${(s:\0:)_PSEP} ${${(j:, :)_PCOND}/#, /})
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


function updateBattery() {
    local REMPFILE="/sys/module/tp_smapi/drivers/platform:smapi/smapi/BAT0/remaining_percent"
    local STATEFILE="/sys/module/tp_smapi/drivers/platform:smapi/smapi/BAT0/state"

    if [ ! -s ${REMPFILE} ]; then
        return
    fi

    local REMP=$(< ${REMPFILE})

    local STATE=${(g::)${:-"\u2301"}}
    local BLOCK44=${(g::)${:-"\u2588"}}
    local BLOCK34=${(g::)${:-"\u259F"}}
    local BLOCK24=${(g::)${:-"\u2584"}}
    local BLOCK14=${(g::)${:-"\u2597"}}
    local BLOCK04=" "

    local _CBATTERY=
    _PBATTERY=
    if [ -s ${STATEFILE} ]; then
        case "$(< ${STATEFILE})" in
            idle)
                _PBATTERY="i"
                _CBATTERY="${_NCOLO}${STATE}%f"
                ;;
            charging)
                _PBATTERY="c"
                _CBATTERY="%2F${STATE}%f"
                ;;
            discharging)
                _PBATTERY="d"
                _CBATTERY="%1F${STATE}%f"
                ;;
        esac
    fi

    # 5 * 4 * 5% = 100%
    # ugly, but i'm too lazy to think of something
    # on the other hand it should be fast instead building strings.. :)
    # p.s. hooray for vim macros
    if [ ${REMP} -gt 95 ]; then
        _PBATTERY+="${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 90 ]; then
        _PBATTERY+="${BLOCK34}${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK34}${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 85 ]; then
        _PBATTERY+="${BLOCK24}${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK24}${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 80 ]; then
        _PBATTERY+="${BLOCK14}${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK14}${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 75 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK44}${BLOCK44}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 70 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK34}${BLOCK44}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK34}${BLOCK44}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 65 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK24}${BLOCK44}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK24}${BLOCK44}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 60 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK14}${BLOCK44}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK14}${BLOCK44}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 55 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK44}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK04}${BLOCK44}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 50 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK34}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK04}${BLOCK34}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 45 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK24}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK04}${BLOCK24}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 40 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK14}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK04}${BLOCK14}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 35 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK44}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK44}${BLOCK44}%f"

    elif [ ${REMP} -gt 30 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK34}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK34}${BLOCK44}%f"

    elif [ ${REMP} -gt 25 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK24}${BLOCK44}"
        _CBATTERY+="%2F${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK24}${BLOCK44}%f"

    elif [ ${REMP} -gt 20 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK14}${BLOCK44}"
        _CBATTERY+="%3F${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK14}${BLOCK44}%f"

    elif [ ${REMP} -gt 15 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK44}"
        _CBATTERY+="%3F${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK44}%f"

    elif [ ${REMP} -gt 10 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK34}"
        _CBATTERY+="%9F${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK34}%f"

    elif [ ${REMP} -gt 5 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK24}"
        _CBATTERY+="%9F${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK24}%f"

    elif [ ${REMP} -gt 0 ]; then
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK14}"
        _CBATTERY+="%1F${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK14}%f"

    else
        _PBATTERY+="${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}"
        _CBATTERY+="%1F${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}${BLOCK04}%f"
    fi


    pelems+=(${_PBATTERY} ${_CBATTERY})
}


function updatePrompt() {
    # global variables
    _SHOMEP= _LHOMEP=
    local _PSEP=${_WS}'\0'${_SEP}'\0'${_WS}
    if [ -z "${SSH_CONNECTION}" ]; then
        concatWith ${_PSEP} ${_LONGWEATHER} ${_LONGDATE} ${_TIME} ${_PBATTERY}; _LHOMEP+=(${reply})
        concatWith ${_PSEP} ${_PWD} ${_SHRTWEATHER} ${_SHRTDATE} ${_TIME} ${_PBATTERY}; _SHOMEP+=(${reply})
    else # prompt for ssh login
        local _LGNATHST=${_LOGIN}'\0'${_HOSTSEP}'\0'${_HOST}
        concatWith ${_PSEP} ${_LGNATHST} ${_LONGDATE} ${_TIME}; _LHOMEP+=(${reply})
        concatWith ${_PSEP} ${_PWD} ${_LGNATHST} ${_SHRTDATE} ${_TIME}; _SHOMEP+=(${reply})
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


function buildPrompt() {
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


precmd_functions+=(updateBattery updatePrompt buildPrompt)
periodic_functions+=(updateWeather)


autoload zsh/terminfo;
if [[ "$terminfo[colors]" -ge 8 ]]; then _FANCY=true; else _FANCY=false; fi


if [ -z "${_SHRTWEATHER}" -o -z "${_LONGWEATHER}" -o -z "${_PBATTERY}" ]; then
    updateWeather
    updateBattery
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
