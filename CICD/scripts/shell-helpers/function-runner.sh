#!/bin/bash

# put this snippet at the end of a shell script to allow you to call any function in that shell script as a command.
#
# foo.sh
# ...
# do_thing() {}
# do_thing_2() {}
#
# # don't include function-runner.sh if foo.sh is sourced.
# if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then 
#     source /scripts/shell-helpers/function-runner.sh
# fi
#
# 
# now you can do ./foo.sh -do_thing 
# or even ./foo.sh --do_thing arg1 arg2
# or even ./foo.sh --do_thing --do_thing_2 

# Main logic to handle multiple function calls
while [[ "${1}" =~ ^- && "${#1}" -gt 1 ]]; do
    FUNCTION_NAME="${1#--}"
    shift
    if declare -f "${FUNCTION_NAME}" > /dev/null; then
        "${FUNCTION_NAME}" "$@"
    else
        echo "Error: Function '${FUNCTION_NAME}' not found."
        exit 1
    fi

    # Shift arguments to move to the next function call
    while [[ "$#" -gt 0 && ! "${1}" =~ ^-- ]]; do
        shift
    done
done
