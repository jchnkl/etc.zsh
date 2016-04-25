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

function truncatePath () {

    local maxlen=${1} ellipsis=${2} nextpwd=${3}
    local c=0 lvl=0 prevpwd=

    if [[ $maxlen -eq 0 ]] { return; }

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
        nextpwd="%${maxlen}<${ellipsis}<${nextpwd}%<<"
    }

    echo "${(%)nextpwd}"

}

function oldpwd()
{
  local oldpwd=${OLDPWD}

  if [ "${OLDPWD#${PWD}/}" = "$(id -un)" ]; then
    oldpwd=${OLDPWD#${PWD}/}
  elif [ "${OLDPWD}" = "${HOME}" ]; then
    oldpwd='~'
  elif [ "${OLDPWD}" = "$(dirname ${PWD})" ]; then
    # oldpwd='..'
    oldpwd=${plainElements[ellipsis]}
  elif [ "${PWD}" = '/' ]; then
    oldpwd=${OLDPWD#/}
  else
    oldpwd=${OLDPWD#${PWD}/}
  fi

  local pwd=${PWD/${HOME}/'~'}

  if [ ! "x${OLDPWD}x" = "xx" -a ! "x${OLDPWD}x" = "x${PWD}x" ]; then
    echo -en "${oldpwd}"
  fi
}

function updatePwdPrompt () {

    local truncatepath=$( truncatePath                 \
                            $(( $( maxLen ) / 4 * 3 )) \
                            ${plainElements[ellipsis]} \
                            ${(%)${:-%~}}              \
                        )

    plainElements+=( "pwd" ${(%)truncatepath}     )
    elementSizes+=(  "pwd" ${#${(%)truncatepath}} )
    colors+=(        "pwd" $_dirc                 )

}

function updateOldpwdPrompt () {

    local oldpwdpath=$( truncatePath                   \
                            $(( $( maxLen ) / 3 ))     \
                            ${plainElements[ellipsis]} \
                            $(oldpwd)                  \
                      )

    plainElements+=( "oldpwd" "${(%)oldpwdpath}"     )
    elementSizes+=(  "oldpwd" ${#${(%)oldpwdpath}}   )
    colors+=(        "oldpwd" $_dirclight            )

}

chpwd_functions+=( updateOldpwdPrompt )

updateOldpwdPrompt

chpwd_functions+=( updatePwdPrompt )

# run at least once on startup to seed values
updatePwdPrompt
