
function _script() {
    local cur prev opts base
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    cmds=$( < $(which isdc-cli)  awk -F'[ (]' '/^function/ {print $2}' )

    COMPREPLY=($(compgen -W "${cmds}" -- ${cur}))
    return 0
}

complete -o nospace -F _script isdc-cli

