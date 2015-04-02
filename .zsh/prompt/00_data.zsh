# colors

if [[ "$TERM" = "linux" ]] {
    local style=dark
} else {
    local style=light
}

if [[ ${style} == "dark" ]] {
    local _norm=14   # 66
    local _tone=59   # 237 # 23 # 240
    local _sout=3
    local _emph=251
    local _dirc=4
    local _yell=1
    local _bg=0
} else {
    local _norm=12  # base00 // #839496
    local _tone=252
    local _sout=3   # yellow // #b58900
    local _emph=10  # base1  // #586e75
    local _dirc=4   # blue   // #268bd2
    local _yell=1   # red    // #dc322f
    local _bg=7     # base02 // #eee8d5
}


typeset -A colors
colors+=( "|"        $_tone )
colors+=( ","        $_tone )
colors+=( "@"        $_tone )
colors+=( "login"    $_sout )
colors+=( "host"     $_sout )


function leftBrktColor () {
    echo "%K{${_bg}}%F{${_tone}}${plainElements[$1]}%f"
}

function rightBrktColor () {
    echo "%K{${_bg}}%F{${_tone}}${plainElements[$1]}%f%k"
}

function historyColor () {
    echo "%F{${_norm}}!%F{${_emph}}%h%f"
}

function bangColor () {
    echo "%(!.%F{1}#%f.%F{4}$%f)"
}


typeset -A colorFunctions
colorFunctions+=( "[" leftBrktColor  )
colorFunctions+=( "]" rightBrktColor )
colorFunctions+=( "!" historyColor   )
colorFunctions+=( "#" bangColor      )


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
