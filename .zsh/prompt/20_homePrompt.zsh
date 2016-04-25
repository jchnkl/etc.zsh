function homePrompt () {
    local maxlen=$( maxLen )

    local mleft= mright= msweather= mlweather=
    typeset -a mleft mright
    mleft=(  "maybeElem" "l" "|" )
    mright=( "maybeElem" "r" "|" )
    msweather=( "maybeElem" "r" "|" "sweather" )
    mlweather=( "maybeElem" "r" "|" "lweather" )

    typeset -a p0 p1 p2 p3 p4 p5 p6 p7
    p0=( "[" "pwd" "<>" "oldpwd" "|" ${(@)mlweather} "ldate" "|" "time" ${(@)mleft} "lbattery" "]" )
    p1=( "[" "pwd" "<>" "oldpwd" "|" ${(@)mlweather} "ldate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p2=( "[" "pwd" "<>" "oldpwd" "|" ${(@)msweather} "ldate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p3=( "[" "pwd" "<>" "oldpwd" "|" ${(@)msweather} "sdate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p4=( "[" "pwd" "<>" "oldpwd" "|" "ldate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p5=( "[" "pwd" "<>" "oldpwd" "|" "sdate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p6=( "[" "pwd" "<>" "oldpwd" "|" "time" ${(@)mleft} "sbattery" "]" )
    p7=( "[" "pwd" "<>" "oldpwd" ${(@)mleft} "sbattery" )
    p8=( "[" "pwd" ${(@)mleft} "sbattery" )
    p9=( "maybeElem" "l" "[" "maybeElem r ] sbattery" )

    for p in p0 p1 p2 p3 p4 p5 p6 p7 p8 p9; {
        if [[ $( calculateSize ${(@P)p} ) -le ${maxlen} ]] {
            buildPrompt ${(@P)p}
            break
        }
    }
}
