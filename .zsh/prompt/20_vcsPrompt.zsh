function vcsPrompt () {
    local maxlen=$( maxLen )

    typeset -a p0 p1 p2 p3 p4 p5
    p0=( "[" "vcs" "|" "ldate" "|" "time" "|" "lbattery" "]" )
    p1=( "[" "vcs" "|" "ldate" "|" "time" "maybeElem" "l" "|" "sbattery" "]" )
    p2=( "[" "vcs" "|" "sdate" "|" "time" "maybeElem" "l" "|" "sbattery" "]" )
    p3=( "[" "vcs" "|" "time" "maybeElem" "l" "|" "sbattery" "]" )
    p4=( "[" "vcs" "maybeElem" "l" "|" "sbattery" "]" )
    p5=( "[" "vcs" "]" )

    for p in p0 p1 p2 p3 p4 p5; {
        if [[ $( calculateSize ${(@P)p} ) -le ${maxlen} ]] {
            buildPrompt ${(@P)p}
            break
        }
    }
}
