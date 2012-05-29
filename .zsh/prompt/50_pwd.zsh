function collapse () {
    local lvl=$1 ellipsis=$2 string=$3

    local left= right= tstart=0 tstop=${#string}
    for i in {1..${#string}}; {
        if [[ ${string[$i]} = '/' && $lvl -gt 0 ]] {
            lvl=$(($lvl - 1))
        } elif [[ ${string[$i]} = '/' && -z "$left" && $lvl -eq 0 ]] {
            if [[ ${string[$(($i + 1))]} = '.' ]] {
                left=${string[0,$(($i + 1))]}
                tstart=$(($i + 2))
            } else {
                left=${string[0,$i]}
                tstart=$(($i + 1))
            }
        } elif [[ ${string[$i]} = '/' && -z "$right" ]] {
            right=${string[$i,$]}
            tstop=$(($i - 1))
            break
        }
    }

    if [[ -z "$left"  ]] {
        print $string
    } else {
        print -P "${left}%2>${ellipsis}>${string[$tstart,$tstop]}%>>${right}"
    }

}

function updatePwdPrompt () {

    local maxlen=$(( $( maxLen ) - 2 ))
    local ellipsis=${plainElements[ellipsis]}

    local c=0 lvl=0 prevpwd= nextpwd=${(%)${:-%~}}

    for i in {1.."${#nextpwd}"}; {
        if [[ "${nextpwd[$i]}" = "/" ]] {
            lvl=$((lvl + 1))
        }
    }

    while [[ ${#nextpwd} -gt ${maxlen} && $c -lt $lvl ]] {

        prevpwd=$nextpwd
        nextpwd=${(%)$(collapse $c $ellipsis $nextpwd)}
        c=$((c + 1))

    }

    if [[ ${#nextpwd} -gt ${maxlen} ]] {
        nextpwd="%${maxlen}<${ellipsis}<%${nextpwd}%<<"
    }

    plainElements+=( "pwd" "${(%)nextpwd}"     )
    elementSizes+=(  "pwd" "${#${(%)nextpwd}}" )
    colors+=(        "pwd" $_dirc              )

}

chpwd_functions+=( updatePwdPrompt )

# run at least once on startup to seed values
updatePwdPrompt
