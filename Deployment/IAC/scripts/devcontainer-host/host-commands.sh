run_host_command() {
    local command_string="$1"
    local bat_file="/scripts/devcontainer-host/script-to-run.bat"
    
    echo "running host command $command_string"
    # Save the string to the .bat file
    echo "$command_string" > "$bat_file"
    
    # Wait for the .bat file to be deleted
    while [ -e "$bat_file" ]; do
        sleep 1
    done
    echo "host command complete"

    # Exit when the .bat file is deleted
    return 0
}