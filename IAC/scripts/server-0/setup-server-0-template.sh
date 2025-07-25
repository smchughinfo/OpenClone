
#!/bin/bash

################################################################################
######## ENVIRONMENT VARIABLES #################################################
################################################################################

setenv() {
    if [ $# -ne 2 ]; then
        echo "Usage: setenv VARIABLE_NAME value"
        return 1
    fi
    
    local var_name="$1"
    local var_value="$2"
    
    # Create profile.d directory if it doesn't exist
    [ ! -d /etc/profile.d ] && mkdir -p /etc/profile.d
    
    # Remove existing entries first to prevent duplicates
    sed -i "/^export ${var_name}=/d" /etc/profile.d/openclone.sh 2>/dev/null || true
    
    # Save to persistent file
    echo "export ${var_name}='${var_value}'" >> /etc/profile.d/openclone.sh
    
    # Export for immediate use
    export "${var_name}=${var_value}"
    
    echo "Set ${var_name} successfully"
}

echo "setup-server-0 complete!"
