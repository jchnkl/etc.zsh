autoload -Uz vcs_info

zstyle ':vcs_info::*' enable git # svn darcs hg
zstyle ':vcs_info:*' max-exports 4
zstyle ':vcs_info:*' stagedstr "%3F"
zstyle ':vcs_info:*' unstagedstr "%9F"
zstyle ':vcs_info:*' check-for-changes true

zstyle ':vcs_info:git+pre-get-data:*:*' hooks updateVCSPrompt
zstyle ':vcs_info:*+*:*' debug false

+vi-updateVCSPrompt () {

    local                 _cgit_prompt="%2F%c%u%b%f%59F:%4F%r.%1>>%s%>>%59F:"
    local           _cgit_prompt_ahead="%2F%c%u%b%f%59F:%4F%r.%9F%1>>%s%>>%59F:"
    local       _cgit_prompt_untracked="%2F%c%u%b%f%59F:%9F%r%4F.%1>>%s%>>%59F:"
    local _cgit_prompt_ahead_untracked="%2F%c%u%b%f%59F:%9F%r%4F.%9F%1>>%s%>>%59F:"

    local                 _sgit_prompt="%b:%r.%1>>%s%>>:"
    local           _sgit_prompt_ahead="%b:%r.%1>>%s%>>!:"
    local       _sgit_prompt_untracked="%b:%r?.%1>>%s%>>:"
    local _sgit_prompt_ahead_untracked="%b:%r?.%1>>%s%>>!:"

    local _git_status="$(git status --short --branch 2>/dev/null)"

    local _git_notAhead=$( echo ${_git_status} | \
                           grep '\[ahead.*\]' 2>&1 >/dev/null; \
                           echo $? \
                         )

    local _git_noUntracked=$( echo ${_git_status} | \
                              grep '??' 2>&1 >/dev/null;  \
                              echo $? \
                            )

    if [ ${_git_notAhead} -eq 1 -a ${_git_noUntracked} -eq 1 ]; then
        _formats=( "${_sgit_prompt}" "${_cgit_prompt}" )
    elif [ ${_git_notAhead} -eq 0 -a ${_git_noUntracked} -eq 1 ]; then
        _formats=( "${_sgit_prompt_ahead}" "${_cgit_prompt_ahead}" )
    elif [ ${_git_notAhead} -eq 1 -a ${_git_noUntracked} -eq 0 ]; then
        _formats=( "${_sgit_prompt_untracked}" "${_cgit_prompt_untracked}" )
    else
        _formats=( "${_sgit_prompt_ahead_untracked}" \
                   "${_cgit_prompt_ahead_untracked}" \
                 )
    fi

    zstyle ':vcs_info:*' formats ${(@)_formats} "%S" "%b:%r.x:"
    zstyle ':vcs_info:*' actionformats ${(@)_formats} "%S" "%b:%r.x:"

}
