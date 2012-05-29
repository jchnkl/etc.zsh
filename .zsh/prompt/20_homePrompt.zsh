function homePrompt () {
    local maxlen=$( maxLen )

    local mleft= mright= msweather= mlweather=
    typeset -a mleft mright
    mleft=(  "maybeElem" "l" "|" )
    mright=( "maybeElem" "r" "|" )
    msweather=( "maybeElem" "r" "|" "sweather" )
    mlweather=( "maybeElem" "r" "|" "lweather" )

    typeset -a p0 p1 p2 p3 p4 p5 p6 p7
    p0=( "[" ${(@)mlweather} "ldate" "|" "time" ${(@)mleft} "lbattery" "]" )
    p1=( "[" ${(@)mlweather} "ldate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p2=( "[" ${(@)msweather} "ldate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p3=( "[" ${(@)msweather} "sdate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p4=( "[" "ldate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p5=( "[" "sdate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p6=( "[" "time" ${(@)mleft} "sbattery" "]" )
    p7=( "maybeElem" "l" "[" "maybeElem r ] sbattery" )

    for p in p0 p1 p2 p3 p4 p5 p6 p7; {
        if [[ $( calculateSize ${(@P)p} ) -le ${maxlen} ]] {
            buildPrompt ${(@P)p}
            break
        }
    }
}
