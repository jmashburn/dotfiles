# shellcheck shell=bash

function _set_ansible_aliases() {
	if _command_exists ansible; then
        alias ans='ansible'
        alias ap='ansible-playbook'
	fi
}

_set_ansible_aliases
