function updateDatePrompt () {

    local sdate=${(%)${:-"%D{%a}, %D{%d}%D{. %b %y}"}}

    shortDateColor () {
        echo "%${_emph}F%D{%a}%f, %${_emph}F%D{%d}%f%${_norm}F%D{. %b %y}%f"
    }

    plainElements+=(  "sdate" ${sdate}       )
    elementSizes+=(   "sdate" ${#sdate}      )
    colorFunctions+=( "sdate" shortDateColor )

    local ldate=${(%)${:-"%D{%A}, %D{%d}%D{. %B %Y}"}}

    longDateColor () {
        echo "%${_emph}F%D{%A}%f, %${_emph}F%D{%d}%f%${_norm}F%D{. %B %Y}%f"
    }

    plainElements+=(  "ldate" ${ldate}      )
    elementSizes+=(   "ldate" ${#ldate}     )
    colorFunctions+=( "ldate" longDateColor )

}

precmd_functions+=( updateDatePrompt )
