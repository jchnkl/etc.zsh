function homePrompt () {
    local maxlen=$( maxLen )

    typeset -a p0 p1 p2 p3 p4
    p0=( "[" "lweather" "|" "ldate" "|" "time" "|" "lbattery" "]" )
    p1=( "[" "lweather" "|" "ldate" "|" "time" "|" "sbattery" "]" )
    p2=( "[" "sweather" "|" "ldate" "|" "time" "|" "sbattery" "]" )
    p3=( "[" "sweather" "|" "sdate" "|" "time" "|" "sbattery" "]" )
    p4=( "[" "ldate" "|" "time" "|" "sbattery" "]" )
    p5=( "[" "sdate" "|" "time" "|" "sbattery" "]" )
    p6=( "[" "time" "|" "sbattery" "]" )
    p7=( "[" "sbattery" "]" )

    for p in p0 p1 p2 p3 p4 p5 p6 p7; {
        if [[ $( calculateSize ${(@P)p} ) -le ${maxlen} ]] {
            buildPrompt ${(@P)p}
            break
        }
    }
}
