
#!/bin/bash

################################################################################
######## GET LATEST OPENCLONE-CICD IMAGE ##################################
################################################################################

get_current_version_tag() {
    i=1
    echo "Checking for existing versions..." >&2
    while true; do
        current_tag="$i.0"
        echo "Checking if version $current_tag exists..." >&2
        if ! docker manifest inspect "ewr.vultrcr.com/openclone/openclone-cicd:$current_tag" >/dev/null 2>&1; then
            # Return the previous tag, as it's the current version
            previous_tag="$(($i - 1)).0"
            if [ "$i" -eq 1 ]; then
                echo "No versions found. Returning 0.0" >&2
                echo "0.0"
            else
                echo "Version $current_tag not found. Latest version is $previous_tag" >&2
                echo "$previous_tag"
            fi
            break
        fi
        echo "Version $current_tag exists. Checking next version..." >&2
        # Increment to check the next version
        i=$(($i + 1))
    done
}

# delete existing containers and container images
docker ps -aq | xargs -r docker rm -f
docker images -q | xargs -r docker rmi -f

# download and install the latest openclone-cicd container
docker login https://ewr.vultrcr.com/openclone -u "${OpenClone_Resistry_User}" -p "${OpenClone_Registry_Password}"
echo "getting latest container version. this will take a while..."
current_version_tag=$(get_current_version_tag)
echo "Latest version found: $current_version_tag"
docker pull ewr.vultrcr.com/openclone/openclone-cicd:$current_version_tag


################################################################################
######## CALL SETUP-CONTAINER.SH ###############################################
################################################################################

# this startup logic is so you can run the container for the first time, run a startup script, and then shut the container down, while retaining environment variables after restarting
# /start-cluster.sh can't rely on the container to be on so just make the desired default state of the container off (exists but not running). 
# /start-cluster.sh should turn the container on, create the vultr clustr, and then turn the container off. 

# 1. Delete the marker file before docker run
rm -f /initial-setup-complete

# 2. Run the container in detached mode with marker file creation
docker run -d \
  --name openclone-cicd \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ewr.vultrcr.com/openclone/openclone-cicd:$current_version_tag \
  bash -c "
    source /scripts/environment.sh
    set_env_variable TF_VAR_postgres_password \"${TF_VAR_postgres_password}\"
    set_env_variable TF_VAR_openclone_openclonedb_password \"${TF_VAR_openclone_openclonedb_password}\"
    set_env_variable TF_VAR_openclone_logdb_password \"${TF_VAR_openclone_logdb_password}\"
    set_env_variable TF_VAR_vultr_api_key \"${TF_VAR_vultr_api_key}\"
    set_env_variable TF_VAR_openclone_jwt_secretkey \"${TF_VAR_openclone_jwt_secretkey}\"
    set_env_variable TF_VAR_openclone_openai_api_key \"${TF_VAR_openclone_openai_api_key}\"
    set_env_variable TF_VAR_openclone_googleclientid \"${TF_VAR_openclone_googleclientid}\"
    set_env_variable TF_VAR_openclone_googleclientsecret \"${TF_VAR_openclone_googleclientsecret}\"
    set_env_variable TF_VAR_openclone_elevenlabsapikey \"${TF_VAR_openclone_elevenlabsapikey}\"
    set_env_variable TF_VAR_openclone_email_dkim \"${TF_VAR_openclone_email_dkim}\"
    set_env_variable Server_0_CICD_ENV \"server-0\"
    set_env_variable OpenClone_Root_Dir \"/\"
    set_env_variable OpenClone_OpenCloneFS \"/OpenCloneFS\"
    terraform -chdir="/terraform" init
    source /setup-container.sh
    switch_environment vultr_dev
    touch /initial-setup-complete
    echo '/initial-setup-complete marker file created'
    tail -f /dev/null
  "

# 3. Poll for the completion marker
echo "Waiting for container setup to complete..."
while ! docker exec openclone-cicd -f /initial-setup-complete 2>/dev/null; do
  sleep 2
  echo -n "."
done
echo ""
echo "Container setup completed successfully!"

# 4. Stop the container
echo "Stopping container..."
docker stop openclone-cicd
echo "Container stopped."

echo "setup-server-0-container complete!"