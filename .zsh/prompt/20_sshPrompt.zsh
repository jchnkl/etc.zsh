function sshPrompt () {
    local maxlen=$( maxLen )

    typeset -a p0 p1 p2 p3 p4
    p0=( "[" "pwd" "|" "login" "@" "host" "|" "ldate" "|" "time" "]" )
    p1=( "[" "pwd" "|" "login" "@" "host" "|" "sdate" "|" "time" "]" )
    p2=( "[" "pwd" "|" "login" "@" "host" "|" "time" "]" )
    p3=( "[" "pwd" "|" "login" "@" "host" "]" )
    p4=( "[" "pwd" "]" )

    for p in p0 p1 p2 p3 p4; {
        if [[ $( calculateSize ${(@P)p} ) -le ${maxlen} ]] {
            buildPrompt ${(@P)p}
            break
        }
    }
}
