function maxLen () {
    echo $(( ${COLUMNS} * 1000 / 1618 ))
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

    local pelems= prompt=
    typeset -A pelems

    for e in $@; do

        if [[ "$terminfo[colors]" -ge 8 ]]; then
            prompt+=$(colorize $e ${plainElements[$e]})
        else
            prompt+=${plainElements[$e]}
        fi

    done

    echo ${(%)prompt}

}
