#!/bin/bash

source /scripts/shell-helpers/aliases.sh
source /scripts/devcontainer-host/host-commands.sh

get_first_pod_with_mount() {
    pod_name=$(k get pods --selector=pod_id=openclone-website-pod --output=jsonpath='{.items[0].metadata.name}')
    echo $pod_name
}

check_init_status() {
    k get configmap openclone-fs-init-status >/dev/null 2>&1
}

mark_init_complete() {
    k create configmap openclone-fs-init-status \
        --from-literal=status=completed \
        --from-literal=timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --from-literal=version="1.0"
}

push_openclone_fs() {
    # Check if initialization was already completed
    if check_init_status; then
        echo "OpenClone FS already initialized (ConfigMap exists), skipping..."
        return 0
    fi
    
    echo "Running OpenClone FS initialization..."
    
    host="dev.sftp.$TF_VAR_openclone_domain_name"
    echo "Flushing DNS to ensure $host uses the right ip address."
    run_host_command "ipconfig /flushdns" # TODO: linux

    port="22"
    username="$TF_VAR_openclone_ftp_user"
    password="$TF_VAR_openclone_ftp_password"
    source_dir="/OpenCloneFS"
    dest_dir="/OpenCloneFS"

    # Use lftp to mirror the local directory to the remote SFTP server, bypassing host key verification
    lftp -u "$username","$password" "sftp://${host}:${port}" <<EOF
set sftp:auto-confirm yes
set sftp:connect-program "ssh -a -x -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
mirror -R "$source_dir" "$dest_dir"
EOF

    # Mark initialization as complete
    if [ $? -eq 0 ]; then
        echo "FS initialization successful, marking as complete..."
        mark_init_complete
        echo "OpenClone FS initialization complete!"
    else
        echo "FS initialization failed, not marking as complete"
        return 1
    fi
}

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi