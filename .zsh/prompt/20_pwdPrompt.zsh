function pwdPrompt () {
    local maxlen=$( maxLen )

    local mleft= mright= mopwd=
    typeset -a mleft mright
    mleft=(  "maybeElem" "l" "|" )
    mright=( "maybeElem" "r" "|" )
    mopwd=( "maybeElem" "l" "<>" )

    typeset -a p0 p1 p2 p3 p4 p5
    p0=( "[" "pwd" ${(@)mopwd} "oldpwd" "|" "ldate" "|" "time" ${(@)mleft} "lbattery" "]" )
    p1=( "[" "pwd" ${(@)mopwd} "oldpwd" "|" "ldate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p2=( "[" "pwd" ${(@)mopwd} "oldpwd" "|" "sdate" "|" "time" ${(@)mleft} "sbattery" "]" )
    p3=( "[" "pwd" ${(@)mopwd} "oldpwd" "|" "time" ${(@)mleft} "sbattery" "]" )
    p4=( "[" "pwd" ${(@)mopwd} "oldpwd" ${(@)mleft} "sbattery" "]" )
    p5=( "[" "pwd" ${(@)mopwd} "oldpwd" "]" )
    p6=( "[" "pwd" "]" )

    for p in p0 p1 p2 p3 p4 p5 p6; {
        if [[ $( calculateSize ${(@P)p} ) -le ${maxlen} ]] {
            buildPrompt ${(@P)p}
            break
        }
    }
}
