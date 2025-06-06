
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
    
    # Save to persistent file
    echo "export ${var_name}='${var_value}'" >> /etc/profile.d/openclone.sh
    
    # Export for immediate use
    export "${var_name}=${var_value}"
    
    echo "Set ${var_name} successfully"
}

setenv OpenClone_Server_0_Cluster_Password "${OpenClone_Server_0_Cluster_Password}"

echo "setup-server-0 complete!"
