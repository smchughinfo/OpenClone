#!/bin/bash

source /scripts/shell-helpers/aliases.sh

get_first_pod_with_mount() {
    pod_name=$(k get pods --selector=pod_id=openclone-website-pod --output=jsonpath='{.items[0].metadata.name}')
    echo $pod_name
}

push_openclone_fs() {
    host=""
    if [[ "$TF_VAR_kube_config_path" == "$kind_kube_config_path" ]]; then
        host="host.docker.internal"
    else
        host="dev.sftp.$TF_VAR_openclone_domain_name"
    fi
    #port="$TF_VAR_sftp_nodeport"
    port="22"
    username="$OpenClone_FTP_User"
    password="$OpenClone_FTP_Password"
    source_dir="$OpenCloneFS_Dir"
    dest_dir="/OpenCloneFS"

    # Use lftp to mirror the local directory to the remote SFTP server, bypassing host key verification
    lftp -u "$username","$password" "sftp://${host}:${port}" <<EOF
set sftp:auto-confirm yes
set sftp:connect-program "ssh -a -x -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
mirror -R "$source_dir" "$dest_dir"
EOF
}

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi