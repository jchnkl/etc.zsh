# splitting of arguments is based on '\0'
function concatWith() {
    local _concatWithSep=${1}; shift;

    reply=(${(s:\0:)1}); shift;
    while [ -n "${1}" ]; do
        reply+=(${(s:\0:)_concatWithSep} ${(s:\0:)1}); shift;
    done
}

function updateWeather() {

    reply=
    local mode=$1 _WS=" " _COMMA=","
    local pelems=
    typeset -A pelems
    pelems+=(${_WS}     "${_WS}")
    pelems+=(${_COMMA}  "%${_tone}F${_COMMA}%f")

    local WEATHERFILE=${HOME}/.zsh/weather
    if [ ! -s ${WEATHERFILE} ]; then
        return
    fi

    local _TEMP="$(grep "Temperature:" ${WEATHERFILE} | cut -d ' ' -f 2)"
    local _WIND="$(grep "Wind:" ${WEATHERFILE} | cut -d ' ' -f 4,8)"
    local _COND="$(grep "Weather:" ${WEATHERFILE} | cut -d ' ' -f 2-)"
    local _SKYC="$(grep "Sky conditions:" ${WEATHERFILE} | cut -d ' ' -f 3-)"

    local TCOLOR
    if [ ${_TEMP} -le 4 ]; then TCOLOR=4 # blue;
    elif [ ${_TEMP} -le 10 ]; then TCOLOR=6 #cyan;
    elif [ ${_TEMP} -le 16 ]; then TCOLOR=2 # green;
    elif [ ${_TEMP} -le 22 ]; then TCOLOR=3 # yellow;
    elif [ ${_TEMP} -le 28 ]; then TCOLOR=5 # magenta;
    else TCOLOR=9 # red;
    fi

    local _PTEMP="%{%${#_TEMP}G${_TEMP}%}°C"
    pelems+=(${_PTEMP} "%${TCOLOR}F%{%${#_TEMP}G${_TEMP}%}%${_norm}F°C%f")

    local _PWIND=
    if [ -n "${_WIND}" ]; then
        _PWIND="%{%${#_WIND}G${_WIND}%}kmh"
        pelems+=(${_PWIND} "%${_norm}F%{%${#_WIND}G${_WIND}%}kmh%f")
    fi

    # global variable
    local _SHRTWEATHER=${_PTEMP}
    pelems[${_SHRTWEATHER}]=${pelems[${_PTEMP}]}

    local _WP= _PSEP=${_COMMA}'\0'${_WS}
    concatWith ${_PSEP} ${_PTEMP} ${_PWIND}; _WP=($reply)

    # Conditions are not always present
    if [ -n "${_COND}" ]; then
        local _PCOND= _CCOND=
        for c in ${(s:\0:S)${_COND}//(; |, )/'\0'}; do # split at commas and semicolons
          _PCOND+=(%{%${#c}G${c}%})
          _CCOND+=(%${_norm}F%{%${#c}G${c}%}%${_tone}F)
        done

        # join with ', '; remove a head comma (, ) if necessary (#)
        pelems+=(${${(j:, :)_PCOND}/#, /} ${${(j:, :)_CCOND}/#, /})
        _WP+=(${(s:\0:)_PSEP} ${${(j:, :)_PCOND}/#, /})
    fi

    # Sky Conditions is not always present
    if [ -n "${_SKYC}" ]; then
        local _PSKYC="%{%${#_SKYC}G${_SKYC}%}"
        pelems+=(${_PSKYC} "%${_norm}F%{%${#_SKYC}G${_SKYC}%}%f")
        _WP+=(${(s:\0:)_PSEP} ${_PSKYC})
    fi

    local _LONGWEATHER= _CLONGWEATHR=
    for e in ${_WP}; do
        _LONGWEATHER+=${e}
        _CLONGWEATHR+=${(v)pelems[${e}]}
    done

    # 1: short nocolor; 2: short color; 3: long nocolor; 4: long color
    reply=( "${_SHRTWEATHER}" "${pelems[${_SHRTWEATHER}]}" \
            "${_LONGWEATHER}" "${_CLONGWEATHR}" \
          )

}

function updateWeatherPrompt () {
    updateWeather

    if [[ -z $reply ]] {
        return
    } else {

        sweathercolor=${reply[2]}
        local sweather=${reply[1]}

        function shortWeatherColor () {
            echo ${sweathercolor}
        }

        plainElements+=(  "sweather" ${sweather}        )
        elementSizes+=(   "sweather" ${#${(%)sweather}} )
        colorFunctions+=( "sweather" shortWeatherColor  )

        lweathercolor=${reply[4]}
        local lweather=${reply[3]}

        function longWeatherColor () {
            echo ${lweathercolor}
        }

        plainElements+=(  "lweather" ${lweather}        )
        elementSizes+=(   "lweather" ${#${(%)lweather}} )
        colorFunctions+=( "lweather" longWeatherColor   )

    }

}

periodic_functions+=( updateWeatherPrompt )

# run at least once at startup to seed values
updateWeatherPrompt
