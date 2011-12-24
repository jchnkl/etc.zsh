PERIOD=300

local fgc=$fg[cyan];	local bgc=$bg[cyan]
local fgw=$fg[white];	local bgw=$bg[white]
local fgy=$fg[yellow];	local bgy=$bg[yellow]
local fgm=$fg[magenta];	local bgm=$bg[magenta]
local fgbk=$fg[black];	local bgbk=$bg[black]
local fgbe=$fg[blue];	local bgbe=$bg[blue]
local fgr=$fg[red];	local bgr=$bg[red]
local fgd=$fg[default];	local bgd=$bg[default]
local fggy=$fg[grey];	local bggy=$bg[grey]
local fggn=$fg[green];	local bggn=$bg[green]
local rc=$reset_color


local LBRKT="%0K%10F[%f"
local RBRKT="%10F]%f%k"
local PCHAR="%(!.%1F#%f.%4F$%f)"
local LOGIN="%14F%n%f@%14F%m%f"
local HIST="%14F!%7F%h%f"
local CURWD="%4F%~%f" 
local PLAINDATETIME="%D{%A, %d. %B %Y %H:%M}"
local FANCYDATETIME="%14F%D{%A}%f, %14F%D{%d. %B %Y %H:%M}%f"

#local FG="%0F A%1F B%2F C%3F D%4F E%5F F%6F G%7F H%8F I%9F J%10F K%11F L%12F M%13F N%14F O%15F P%16F R%17F S%18F %f"
#local BG="%0K A%1K B%2K C%3K D%4K E%5K F%6K G%7K H%8K I%9K J%10K K%11K L%12K M%13K N%14K O%15K P%16K R%17K S%18K %k"

function updateWeather() {
    local WEATHERFILE=${HOME}/.zsh/weather
    local TEMP=$(grep "Temperature:" ${WEATHERFILE} | cut -d ' ' -f 2)
    local WIND="$(grep "Wind:" ${WEATHERFILE} | cut -d ' ' -f 4,8)"
    local COND="$(grep "Weather:" ${WEATHERFILE} | cut -d ' ' -f 2-)"
    local SKYCOND="$(grep "Sky conditions:" ${WEATHERFILE} | cut -d ' ' -f 3-)"
    if [ $TEMP -le 4 ]; then TEMPCOLOR=blue;
    elif [ $TEMP -le 10 ]; then TEMPCOLOR=cyan;
    elif [ $TEMP -le 16 ]; then TEMPCOLOR=green;
    elif [ $TEMP -le 22 ]; then TEMPCOLOR=yellow;
    elif [ $TEMP -le 28 ]; then TEMPCOLOR=magenta;
    else TEMPCOLOR=red;
    fi

    COLOREDTEMP="%{$fg[${TEMPCOLOR}]%}%{%2G${TEMP}%}%{$fg[default]%}%14F°C%f"

    if [ -z $COND ]; then 
        PLAINWEATHER="${TEMP}°C"
        FANCYWEATHER="${COLOREDTEMP}"
        #PLAINWEATHER="${TEMP}°C, ${WIND}kmh, ${SKYCOND}"
        #FANCYWEATHER="${COLOREDTEMP}, %14F${WIND}kmh%f, %14F${SKYCOND}%f"
    else
        PLAINWEATHER="${TEMP}°C"
        FANCYWEATHER="${COLOREDTEMP}"
        #PLAINWEATHER="${TEMP}°C, ${WIND}kmh, ${COND}, ${SKYCOND}"
        #FANCYWEATHER="$LBRKT${COLOREDTEMP}, %14F${WIND}kmh%f, %14F${COND}%f, %14F${SKYCOND}%f$RBRKT"
    fi
}

[ -z $FANCYWEATHER ] && updateWeather

periodic_functions+=(updateWeather)

function precmd {
    local PLAINTOP="[$PLAINWEATHER, ${(%)PLAINDATETIME}]"
    local TERMWIDTH=$((${COLUMNS}-1))
    local TOPFILL=${(l.$((${TERMWIDTH} - ${#PLAINTOP})).. .)}
    local FANCYTOP="${FANCYWEATHER}, ${FANCYDATETIME}"

    PROMPT="${TOPFILL}${LBRKT}${FANCYTOP}${RBRKT}
${LBRKT}${HIST} ${PCHAR}${RBRKT} "

    RPROMPT="${LBRKT}${CURWD} ${LOGIN}${RBRKT}"
}
