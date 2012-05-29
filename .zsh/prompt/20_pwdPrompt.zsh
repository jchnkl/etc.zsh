function pwdPrompt () {
    local maxlen=$( maxLen )

    typeset -a p0 p1 p2 p3 p4
    p0=( "[" "pwd" "|" "ldate" "|" "time" "|" "lbattery" "]" )
    p1=( "[" "pwd" "|" "ldate" "|" "time" "|" "sbattery" "]" )
    p2=( "[" "pwd" "|" "sdate" "|" "time" "|" "sbattery" "]" )
    p3=( "[" "pwd" "|" "time" "|" "sbattery" "]" )
    p4=( "[" "pwd" "|" "sbattery" "]" )
    p5=( "[" "pwd" "]" )

    for p in p0 p1 p2 p3 p4 p5; {
        if [[ $( calculateSize ${(@P)p} ) -le ${maxlen} ]] {
            buildPrompt ${(@P)p}
            break
        }
    }
}
