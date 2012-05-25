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
        local _LTIME=" ${_PHORS}:${_PMINS} "
        local _STIME="${_STATEI}${_PHORS}:${_PMINS}"
        local _CLTIME= _CSTIME=
        local _FG2="%0F"

        if [ ${REMP} -gt 94 ]; then
            local C=2
            _CLTIME="%${C}K${_FG2} ${_STIME}%f %k"
            _CSTIME="%${C}K${_FG2}${_STIME}%f%k"

        elif [ ${REMP} -gt 73 ]; then
            local C=2
            _CLTIME=" %${C}K${_FG2}${_STIME}%f %k"
            _CSTIME="%${C}K${_FG2}${_STIME}%f%k"

        elif [ ${REMP} -gt 52 ]; then
            local C=2
            _CLTIME=" ${_CSTATE}%${C}K${_FG2}${_PHORS}:${_PMINS}%f %k"
            _CSTIME="${_CSTATE}%${C}K${_FG2}${_PHORS}:${_PMINS}%f%k"

        elif [ ${REMP} -gt 32 ]; then
            local C=2
            _CTIME="%${C}F${_PHORS[1]}${_FG2}%${C}K${_PHORS[2]:-0}:${_PMINS}%f"
            _CLTIME=" ${_CSTATE}${_CTIME} %k"
            _CSTIME="${_CSTATE}${_CTIME}%k"

        elif [ ${REMP} -gt 20 ]; then
            local C=3
            _CTIME="%${C}F${_PHORS}${_FG2}%${C}K:${_PMINS}%f"
            _CLTIME=" ${_CSTATE}${_CTIME} %k"
            _CSTIME="${_CSTATE}${_CTIME}%k"

        elif [ ${REMP} -gt 12 ]; then
            local C=3
            _CTIME="%${C}F${_PHORS}:${_FG2}%${C}K${_PMINS}%f"
            _CLTIME=" ${_CSTATE}${_CTIME} %k"
            _CSTIME="${_CSTATE}${_CTIME}%k"

        elif [ ${REMP} -gt 8 ]; then
            local C=9
            _CTIME="%${C}F${_PHORS}:${_PMINS[1]:-0}${_FG2}%${C}K${_PMINS[2]:-0}%f"
            _CLTIME=" ${_CSTATE}${_CTIME} %k"
            _CSTIME="${_CSTATE}${_CTIME}%k"

        elif [ ${REMP} -gt 4 ]; then
            local C=1
            _CTIME="%${C}F${_PHORS}:${_PMINS}%f"
            _CLTIME=" ${_CSTATE}${_CTIME}%${C}K %k"
            _CSTIME="${_CSTATE}${_CTIME}%${C}K%k"

        else
            local C=1
            _CTIME="%${C}F${_PHORS}:${_PMINS}%f"
            _CLTIME=" ${_CSTATE}${_CTIME} "
            _CSTIME="${_CSTATE}${_CTIME}"

        fi

        reply=(${_STIME} ${_CSTIME} ${_STIME} ${_CLTIME})
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


