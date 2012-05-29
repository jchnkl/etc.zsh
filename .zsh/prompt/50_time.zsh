function updateTimePrompt () {

    local ptime=${(%)${:-"%D{%H:%M}"}}

    plainElements+=( "time" ${ptime}  )
    elementSizes+=(  "time" ${#ptime} )
    colors+=(        "time" ${_emph}  )

}

precmd_functions+=( updateTimePrompt )
