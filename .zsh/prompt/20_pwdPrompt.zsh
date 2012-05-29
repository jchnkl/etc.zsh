function pwdPrompt () {
    local maxlen=$( maxLen )

    local mleft= mright=
    typeset -a mleft mright
    mleft=(  "maybeElem" "l" "|" )
    mright=( "maybeElem" "r" "|" )

    typeset -a p0 p1 p2 p3 p4 p5
    p0=( "[" "pwd" "|" "ldate" "|" "time" ${(@)mleft} "lbattery" "]" )
    p1=( "[" "pwd" "|" "ldate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p2=( "[" "pwd" "|" "sdate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p3=( "[" "pwd" "|" "time" ${(@)mleft} "sbattery" "]" )
    p4=( "[" "pwd" ${(@)mleft} "sbattery" "]" )
    p5=( "[" "pwd" "]" )

    for p in p0 p1 p2 p3 p4 p5; {
        if [[ $( calculateSize ${(@P)p} ) -le ${maxlen} ]] {
            buildPrompt ${(@P)p}
            break
        }
    }
}
