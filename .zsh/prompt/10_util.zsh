function maxLen () {
    echo $(( ${COLUMNS} * 1000 / 1618 ))
}

function maybeElem () {
    local side=$1 s=$2 e=$3 res=
    typeset -a res

    reply=
    if [[ $e =~ "^$0.*" ]] {
        eval "${(ps: :)e}"
    }

    if [[ -n "${(@)reply}" ]] {
        res=( $reply )
    } elif [[ ${elementSizes[$e]} -ne 0 ]] {
        res=( $e )
    } else {
        res=( )
    }

    if [[ -n "${(@)res}" && ${side} = "l" ]] {
        reply=( $s $res )
    } elif [[ -n "${(@)res}" && ${side} = "r" ]] {
        reply=( $res $s )
    } else {
        reply=
    }
}

function calculateSize () {
    local size=0

    for e in $@; {
        size=$(( $size + ${elementSizes[$e]:-0} ))
    }

    echo $size
}

function colorize () {
    local e=$1 string=$2

    if [[ -n "${colors[$e]}" ]] {
        echo "%${colors[$e]}F${string}%f"
    } elif [[ -n "${colorFunctions[$e]}" ]] {
        echo $(eval ${colorFunctions[$e]} ${(q)string})
    } else {
        echo $string
    }
}

function buildPrompt () {

    local elems= prompt=
    typeset -a elems

    elems=( $@ )

    local n=1
    while [[ $n -le ${#elems} ]] {
        local e=${elems[n]}

        if [[ $e = "maybeElem" ]] {

            eval "maybeElem \${elems[n+1]} \${elems[n+2]} \${elems[n+3]}"
            prompt+=$( buildPrompt $reply )
            n=$(( n + 3 ))

        } elif [[ "$terminfo[colors]" -ge 8 ]] {
            prompt+=$(colorize $e ${plainElements[$e]})
        } else {
            prompt+=${plainElements[$e]}
        }

        n=$(( n + 1 ))

    }

    echo ${prompt}

}
