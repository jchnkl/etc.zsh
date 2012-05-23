# global variables: pelems _LONGWEATHER _SHRTWEATHER _SHOMEP _LHOMEP
#
# TODO
# updateWeather: check age of file and (don't) update
# vcs_info: (g)it, (h)g, (s)vn -> red: unstaged, yellow: uncommited, green: ok
# g:(collapsed_git_root)/path/within/git
# if right prompt > (columns - leftprompt), collapse:
# remove weather, date, etc, then collapse directory
# if dir too long put it in line above
#

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
# local _VCS="${vcs_info_msg_0_}";


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
# pelems+=(${_VCS}	"${vcs_info_msg_0_}")




    fi









function updateBattery() {

    local days= hours= mins=
    function splitTime() {
        days= hours= mins=
        local _TIME=$1
        local _D=$(( (${_TIME} / 60) / 24 ))
        local _H=$(( (${_TIME} - (${_D} * 24 * 60)) / 60 ))
        local _M=$(( ${_TIME} % 60 ))

        while [[ ${_D} -gt 0 ]]; do
            days=($((${_D} % 10)) $days);
            _D=$((${_D} / 10));
        done

        while [[ ${_H} -gt 0 ]]; do
            hours=($((${_H} % 10)) $hours);
            _H=$((${_H} / 10));
        done

        while [[ ${_M} -gt 0 ]]; do
            mins=($((${_M} % 10)) $mins);
            _M=$((${_M} / 10));
        done
    }


    function buildBar() {
        local _PHORS="$(printf "% 2i" ${(j::)hours:-0})"
        local _PMINS="$(printf "%02i" ${(j::)mins})"
        local _PTIME=" ${_PHORS}:${_PMINS} "
        local _CTIME=
        local _FG2="%0F"

        if [ ${REMP} -gt 84 ]; then
            local C=2
            _CTIME="%${C}K${_FG2}${_PTIME}%f%k"

        elif [ ${REMP} -gt 52 ]; then
            local C=2
            _CTIME=" %${C}K${_FG2}${_PHORS}:${_PMINS}%f %k"

        elif [ ${REMP} -gt 32 ]; then
            local C=2
            _CTIME="%${C}F${_PHORS[1]}${_FG2}%${C}K${_PHORS[2]:-0}:${_PMINS}%f"
            _CTIME=" ${_CTIME} %k"

        elif [ ${REMP} -gt 20 ]; then
            local C=2
            _CTIME="%${C}F${_PHORS}${_FG2}%${C}K:${_PMINS}%f"
            _CTIME=" ${_CTIME} %k"

        elif [ ${REMP} -gt 12 ]; then
            local C=3
            _CTIME="%${C}F${_PHORS}:${_FG2}%${C}K${_PMINS}%f"
            _CTIME=" ${_CTIME} %k"

        elif [ ${REMP} -gt 8 ]; then
            local C=9
            _CTIME="%${C}F${_PHORS}:${_PMINS[1]:-0}${_FG2}%${C}K${_PMINS[2]:-0}%f"
            _CTIME=" ${_CTIME} %k"

        elif [ ${REMP} -gt 4 ]; then
            local C=1
            _CTIME="%${C}F${_PHORS}:${_PMINS}%f"
            _CTIME=" ${_CTIME}%${C}K %k"

        else
            local C=1
            _CTIME="%${C}F${_PHORS}:${_PMINS}%f"
            _CTIME=" ${_CTIME} "

        fi

        reply=(${_PTIME} ${_CTIME})
    }


    local REMPFILE="/sys/module/tp_smapi/drivers/platform:smapi/smapi/BAT0/remaining_percent"
    local RUNFILE="/sys/module/tp_smapi/drivers/platform:smapi/smapi/BAT0/remaining_running_time"
    local CHARGEFILE="/sys/module/tp_smapi/drivers/platform:smapi/smapi/BAT0/remaining_charging_time"
    local STATEFILE="/sys/module/tp_smapi/drivers/platform:smapi/smapi/BAT0/state"

    if [ -r "/sys/module/tp_smapi/drivers/platform:smapi/smapi/BAT0/installed" ]; then
        local INSTALLED=$(< "/sys/module/tp_smapi/drivers/platform:smapi/smapi/BAT0/installed")
    else
        return
    fi

    if [ ! -s ${REMPFILE} -o ! -s ${RUNFILE} -o ! -s ${CHARGEFILE} -o ! -s ${STATEFILE} -o ${INSTALLED} = "0"  ]; then
        return
    fi

    local REMP=$(< ${REMPFILE})
    local RUNTIME=$(< ${RUNFILE})
    local CHARGETIME=$(< ${CHARGEFILE})


    local _STATEI=
    case "$(< ${STATEFILE})" in
        idle)
            _STATEI="i"; #_CBATTERY="${_NCOLO}${_PBATTERY}%f"
            ;;
        charging)
            _STATEI="c"; #_CBATTERY="%2F${_PBATTERY}%f"
            ;;
        discharging)
            _STATEI="d"; #_CBATTERY="%1F${_PBATTERY}}%f"
            ;;
    esac


    if [[ ${RUNTIME} =~ "^[[:digit:]+]" ]]; then
        splitTime ${RUNTIME}
    elif [[ ${CHARGETIME} =~ "^[[:digit:]+]" ]]; then
        splitTime ${CHARGETIME}
    else
        days=(" " " "); hours=(" " " "); mins=(" " " ")
    fi
    buildBar


    function test() {
        for c in 3 7 11 19 31 51 83 100; do
            for t in 5 11 121; do
                REMP=$c
                splitTime $t
                #echo "remp: $REMP; days: $days; hours: $hours; mins: $mins"
                buildBar
                echo "x${(%)reply[2]}x        x${(%)reply[1]}x remp: $REMP"
            done
        done
    }


    _PBATTERY="${reply[1]}${_STATEI}"
    pelems+=(${_PBATTERY} "${reply[2]}${_STATEI}")

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


#if [ -z "${_SHRTWEATHER}" -o -z "${_LONGWEATHER}" -o -z "${_PBATTERY}" ]; then
    #updateWeather
    #updateBattery
    #updatePrompt
#fi


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
