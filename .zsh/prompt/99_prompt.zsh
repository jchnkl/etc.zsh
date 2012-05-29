function setPrompts () {

PROMPT="
$( buildPrompt "[" "!" " " "#" "]" )"

    if [[ -n "${SSH_CONNECTION}" ]] {
        RPROMPT=$( sshPrompt )
    } elif [[ ${PWD} = ${HOME} ]] {
        RPROMPT=$( homePrompt )
    } elif [[ -n "${vcs_info_message_0_}" ]] {
        RPROMPT=$( vcsPrompt )
    } else {
        RPROMPT=$( pwdPrompt )
    }

}

precmd_functions+=( setPrompts )
