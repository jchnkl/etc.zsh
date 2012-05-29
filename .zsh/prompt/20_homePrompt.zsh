function homePrompt () {
    local maxlen=$( maxLen )

    local mleft= mright=
    typeset -a mleft mright
    mleft=(  "maybeElem" "l" "|" )
    mright=( "maybeElem" "r" "|" )

    typeset -a p0 p1 p2 p3 p4 p5 p6 p7
    p0=( "[" "lweather" "|" "ldate" "|" "time" ${(@)mleft} "lbattery" "]" )
    p1=( "[" "lweather" "|" "ldate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p2=( "[" "sweather" "|" "ldate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p3=( "[" "sweather" "|" "sdate" "|" "time" ${(@)mleft} "sbattery" "]" )
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
