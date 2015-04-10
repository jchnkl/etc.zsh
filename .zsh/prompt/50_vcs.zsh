autoload -Uz vcs_info

zstyle ':vcs_info::*' enable git # svn darcs hg
zstyle ':vcs_info:*' max-exports 5
zstyle ':vcs_info:*' stagedstr "%3F"
zstyle ':vcs_info:*' unstagedstr "%9F"
zstyle ':vcs_info:*' formats "%b" "%r" "%s" "%S" "%c%u"
zstyle ':vcs_info:*' actionformats "%b" "%r" "%s" "%S" "%c%u"
zstyle ':vcs_info:*' check-for-changes true

zstyle ':vcs_info:git+pre-get-data:*:*' hooks updateVCSPrompt
zstyle ':vcs_info:*+*:*' debug false


local _vcs_dot="." _vcs_sep=":"

plainElements+=( "vcs_dot" ${_vcs_dot} )
plainElements+=( "vcs_sep" ${_vcs_sep} )

elementSizes+=( "vcs_dot" ${#_vcs_dot} )
elementSizes+=( "vcs_sep" ${#_vcs_sep} )

colors+=( "vcs_dot"    $_dirc )
colors+=( "vcs_sep"    $_tone )
colors+=( "vcs_subdir" $_dirc )

function _vcs_dirty_color  () { echo "%9F${1}%f"                   }
function _vcs_clean_color  () { echo "%${_dirc}F${1}%f"            }
function _vcs_branch_color () { echo "%2F${vcs_info_msg_4_}${1}%f" }

colorFunctions+=( "vcs_branch"       _vcs_branch_color )

local px= p0= p1= p2= p3= p4=
typeset -a pX p0 p1 p2 p3 p4
px=( "vcs_branch" "vcs_sep" )
p0=( $px "vcs_long_repo"  "vcs_dot" "vcs_long_vcs"  )
p1=( $px "vcs_long_repo"  "vcs_dot" "vcs_short_vcs" )
p2=( $px "vcs_short_repo" "vcs_dot" "vcs_short_vcs" )
p3=(     "vcs_short_repo" "vcs_dot" "vcs_short_vcs" )
p4=( )


+vi-updateVCSPrompt () {

    local _git_status="$(git status --short --branch 2>/dev/null)"

    local _git_notAhead=$( echo ${_git_status} | \
                           grep '\[ahead.*\]' 2>&1 >/dev/null; \
                           echo $? \
                         )

    local _git_noUntracked=$( echo ${_git_status} | \
                              grep '??' 2>&1 >/dev/null;  \
                              echo $? \
                            )

    colorFunctions+=( "vcs_long_repo"    _vcs_clean_color  )
    colorFunctions+=( "vcs_long_vcs"     _vcs_clean_color  )
    colorFunctions+=( "vcs_short_repo"   _vcs_clean_color  )
    colorFunctions+=( "vcs_short_vcs"    _vcs_clean_color  )

    if [ ${_git_notAhead} -eq 0 -a ${_git_noUntracked} -eq 1 ]; then
        colorFunctions+=( "vcs_long_vcs"     _vcs_dirty_color  )
        colorFunctions+=( "vcs_short_vcs"    _vcs_dirty_color  )
    elif [ ${_git_notAhead} -eq 1 -a ${_git_noUntracked} -eq 0 ]; then
        colorFunctions+=( "vcs_long_repo"    _vcs_dirty_color  )
        colorFunctions+=( "vcs_short_repo"   _vcs_dirty_color  )
    elif [ ${_git_notAhead} -eq 0 -a ${_git_noUntracked} -eq 0 ]; then
        colorFunctions+=( "vcs_long_repo"    _vcs_dirty_color  )
        colorFunctions+=( "vcs_long_vcs"     _vcs_dirty_color  )
        colorFunctions+=( "vcs_short_repo"   _vcs_dirty_color  )
        colorFunctions+=( "vcs_short_vcs"    _vcs_dirty_color  )
    fi

}

updateVcsPrompt () {

    vcs_info

    if [[ -z ${vcs_info_msg_0_} ]] {
        return
    }

    local trunpathlen= maxlen=$( maxLen ) ellipsis=${plainElements[ellipsis]}

    local _vcs_prompt= _vcs_prompt_len= _vcs_prompt_maxlen=

    if [[ ! -z ${VCSH_REPO_NAME} ]]; then
        vcs_info_msg_1_="vcsh:${VCSH_REPO_NAME}"
    fi

    local _vcs_branch=${vcs_info_msg_0_}                         \
          _vcs_long_repo=${vcs_info_msg_1_}                      \
          _vcs_short_repo="%8>${ellipsis}>${vcs_info_msg_1_}%>>" \
          _vcs_long_vcs="${vcs_info_msg_2_}"                     \
          _vcs_short_vcs="%1>>${vcs_info_msg_2_}%>>"

    plainElements+=( "vcs_branch"       ${_vcs_branch}        )
    plainElements+=( "vcs_long_repo"    ${_vcs_long_repo}     )
    plainElements+=( "vcs_long_vcs"     ${_vcs_long_vcs}      )
    plainElements+=( "vcs_short_repo"   ${(%)_vcs_short_repo} )
    plainElements+=( "vcs_short_vcs"    ${(%)_vcs_short_vcs}  )

    elementSizes+=( "vcs_branch"       ${#_vcs_branch}           )
    elementSizes+=( "vcs_long_repo"    ${#_vcs_long_repo}        )
    elementSizes+=( "vcs_long_vcs"     ${#_vcs_long_vcs}         )
    elementSizes+=( "vcs_short_repo"   ${#${(%)_vcs_short_repo}} )
    elementSizes+=( "vcs_short_vcs"    ${#${(%)_vcs_short_vcs}}  )

    if [[ ${#vcs_info_msg_3} -ge $(( ${maxlen} / 2 )) ]] {
        _vcs_prompt_maxlen=$(( ${maxlen} / 2 ))
    } else {
        _vcs_prompt_maxlen=$(( ${maxlen} - ${#vcs_info_msg_3_} )) # - 3 ))
    }

    for p in p0 p1 p2 p3; {
        _vcs_prompt_len=$(( $( calculateSize ${(@P)p} ) ))
        if [[ ${_vcs_prompt_len} -le $(( ${_vcs_prompt_maxlen} )) ]] {
            _vcs_prompt=$( buildPrompt ${(@P)p} )
            break
        }
    }

    if [[ ${#_vcs_prompt} -le 2 ]] {
        trunpathlen=$(( ${maxlen} - 2 ))
    } else {
        trunpathlen=$((${maxlen} - ${_vcs_prompt_len} - 3))
    }

    local truncatepath=$( truncatePath                              \
                            ${trunpathlen}                          \
                            ${plainElements[ellipsis]}              \
                            ${vcs_info_msg_3_}                      \
                        )

    if [[ ${#truncatepath} -le 2 ]] {

        plainElements+=( "vcs" ${_vcs_prompt} )
        elementSizes+=(  "vcs" $(( ${_vcs_prompt_len} )) )

    } elif [[ ${#_vcs_prompt} -le 2 ]] {

        plainElements+=( "vcs_subdir" ${(%)truncatepath}     )
        elementSizes+=(  "vcs_subdir" ${#${(%)truncatepath}} )

        plainElements+=( "vcs" $( buildPrompt vcs_subdir ) )
        elementSizes+=(  "vcs" ${elementSizes[vcs_subdir]} )

    } else {

        plainElements+=( "vcs_subdir" ${(%)truncatepath}     )
        elementSizes+=(  "vcs_subdir" ${#${(%)truncatepath}} )

        plainElements+=( "vcs"                                             \
                         ${_vcs_prompt}$( buildPrompt vcs_sep vcs_subdir ) \
                       )

        elementSizes+=( "vcs" $(( ${_vcs_prompt_len}          \
                                + ${elementSizes[vcs_sep]}    \
                                + ${elementSizes[vcs_subdir]} \
                                )) \
                      )

    }

}

precmd_functions+=( updateVcsPrompt )
