#!/bin/bash

# Created by Jose Luis Mantilla 2020
# email: joseluismantilla@gmail.com
#
# Features
# bsupport-vm command tab-completion 
# If you want to use it with dynamical values, exchange the lines 19 by 20 and 31 by 32.
#

_bsupportvm_completion() 
{
    local cur prev opts base
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

if [[ $prev == "bsupport-devops-vm" ]]; then
	base="jenkins kubernetes node registry list"
    COMPREPLY=( $(compgen -W "${base}" -- ${cur}) )
    return 0
else
    case "${prev}" in
        jenkins)
            opts="centos ubuntu"
            COMPREPLY=( $(compgen -W "$opts" ${cur}) )
            return 0
        ;;
        kubernetes)
            opts="centos ubuntu"
            COMPREPLY=( $(compgen -W "$opts" ${cur}) )
            return 0
        ;;
        node)
	    local running="jenkins kubernetes"
            COMPREPLY=( $(compgen -W "${running}" -- ${cur}) )
	    return 0
	;;
        *)
        ;;
    esac
    
fi
}
complete -F _bsupportvm_completion bsupport-devops-vm
