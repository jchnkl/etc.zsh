function setPrompts () {

PROMPT="
$( buildPrompt "[" "!" " " "#" "]" " " )"

    if [[ -n "${SSH_CONNECTION}" ]] {
        RPROMPT=$( sshPrompt )
    } elif [[ -n "${vcs_info_msg_0_}" ]] {
        RPROMPT=$( vcsPrompt )
    } elif [[ ${PWD} = ${HOME} ]] {
        RPROMPT=$( homePrompt )
    } else {
        RPROMPT=$( pwdPrompt )
    }

}

precmd_functions+=( setPrompts )
