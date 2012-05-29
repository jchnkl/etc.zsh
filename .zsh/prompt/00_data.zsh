# colors
local _norm=14   # 66
local _tone=59   # 237 # 23 # 240
local _sout=3
local _emph=251
local _dirc=4
local _yell=1


typeset -A colors
colors+=( "|"        $_tone )
colors+=( ","        $_tone )
colors+=( "@"        $_tone )
colors+=( "login"    $_sout )
colors+=( "host"     $_sout )


function leftBrktColor () {
    echo "%0K%${_tone}F${plainElements[$1]}%f"
}

function rightBrktColor () {
    echo "%${_tone}F${plainElements[$1]}%f%k"
}

function historyColor () {
    echo "%${_norm}!%${_emph}F${plainElements[$1]}%f"
}

function bangColor () {
    echo "%(!.%1F#%f.%4F$%f)"
}


typeset -A colorFunctions
colorFunctions+=( "[" leftBrktColor  )
colorFunctions+=( "]" rightBrktColor )
colorFunctions+=( "!" historyColor   )
colorFunctions+=( "#" bangColor      )


function mkHistPrompt () {
    #local HEVENTS=${(l.3..0.)$((${HISTCMD} % 1000))}
    local HEVENTS="%h"
    cprompt+=( "!" "${_NCOLO}!${_EMPH}${HEVENTS}%f" )
    sprompt+=( "!" "!${HEVENTS}" )
}

typeset -A plainElements
plainElements+=( " "        " "                )
plainElements+=( "|"        " ${(#)${:-166}} " )
plainElements+=( ","        ","                )
plainElements+=( "["        "["                )
plainElements+=( "]"        "]"                )
plainElements+=( "@"        "@"                )
plainElements+=( "!"        "!%h"              )
plainElements+=( "#"        "%(!.#.$)"         )
plainElements+=( "login"    "%n"               )
plainElements+=( "host"     "%2m"              )
plainElements+=( "ellipsis" "${(#)${:-8229}}"  )


typeset -A elementSizes
elementSizes+=( " "        ${#plainElements[ ]}             )
elementSizes+=( "|"        ${#plainElements[|]}             )
elementSizes+=( ","        ${#plainElements[,]}             )
elementSizes+=( "["        ${#plainElements[\[]}            )
elementSizes+=( "]"        ${#plainElements[\]]}            )
elementSizes+=( "@"        ${#plainElements[${:-@}]}        )
elementSizes+=( "!"        ${#${(%)plainElements[!]}}  )
elementSizes+=( "#"        ${#${(%)plainElements[${:-#}]}}  )
elementSizes+=( "login"    ${#${(%)plainElements[login]}}   )
elementSizes+=( "host"     ${#${(%)plainElements[host]}}    )
elementSizes+=( "ellipsis" ${#plainElements[ellipsis]}      )
