function sshPrompt () {
    local maxlen=$( maxLen )

    typeset -a p0 p1 p2 p3 p4

    p0=( "login" "@" "host" "|" "ldate" "|" "time" )
    p1=( "login" "@" "host" "|" "sdate" "|" "time" )
    p2=( "login" "@" "host" "|" "time" )
    p3=( "login" "@" "host" )
    p4=( )

    for p in p0 p1 p2 p3 p4; {

        typeset -a prmpt

        if [[ -n "${vcs_info_msg_0_}" ]] {
            prmpt=( "vcs" )
        } elif [[ ${PWD} != ${HOME} ]] {
            prmpt=( "pwd" )
        }

        if [[ -n ${(P)p} && -n $prmpt ]] {
            prmpt=( "[" ${(@)prmpt} "|" ${(@P)p} "]" )
        } elif [[ -z ${(P)p} && -n $prmpt ]] {
            prmpt=( "[" ${(@)prmpt} "]" )
        } elif [[ -n ${(P)p} ]] {
            prmpt=( "[" ${(@P)p} "]" )
        } else {
            prmpt=( )
        }

        if [[ $( calculateSize ${(@)prmpt} ) -le ${maxlen} ]] {
            buildPrompt ${(@)prmpt}
            break
        }
    }
}
