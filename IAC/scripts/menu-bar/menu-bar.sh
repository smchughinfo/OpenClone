#!/bin/bash

source /scripts/database/database.sh
source /scripts/menu-bar/server-logs.sh
source /scripts/shell-helpers/aliases.sh

function MENU_get_nodes {
    k get nodes -o wide
}

function MENU_get_pods {
    k get pods -o wide
}

function MENU_get_service_endpoints {
    k get endpoints -o wide
}

function MENU_get_state {
    terraform state list -state=/vultr-terraform/vultr/terraform.tfstate
    terraform state list -state=/vultr-terraform/kubernetes/terraform.tfstate
}

function MENU_describe_service {
    k describe svc
}

function MENU_port_forward_website_KIND {
    # Kill any existing port-forward processes for port 8080
    pkill -f "port-forward.*8080:80" || true
    
    # Start the new port-forward in the background
    k port-forward service/openclone-website-nodeport 8080:80 > /dev/null 2>&1 &
    
    echo "Port forwarding started in background. Access at http://localhost:8080"
}

function MENU_get_nodeport_external_addresses {
    # Get all external IPv4 addresses for nodes
    hosts=$(k get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')

    # Loop through each NodePort service and get its port
    for service in $(k get svc --field-selector spec.type=NodePort -o jsonpath='{.items[*].metadata.name}'); do
        port=$(k get svc "$service" -o jsonpath='{.spec.ports[0].nodePort}')
        
        # Print each host:port combination with service name for the current NodePort service
        for host in $hosts; do
            echo "$service - $host:$port"
        done
    done
}

function MENU_remote_shell {
    # Get all pods in the current namespace
    pods=($(k get pods --no-headers | awk '{print $1}'))

    # Check if there are any pods
    if [[ ${#pods[@]} -eq 0 ]]; then
        echo "No pods found in the current namespace."
        return
    fi

    echo "Available pods:"
    i=1
    for pod in "${pods[@]}"; do
        echo "$i. $pod"
        i=$((i+1))
    done

    read -p "Please enter a value: " choice

    if [[ $choice -ge 1 && $choice -le ${#pods[@]} ]]; then
        selected_pod=${pods[$((choice-1))]}
        
        # Check if there are multiple containers in the pod
        containers=($(k get pod $selected_pod -o jsonpath='{.spec.containers[*].name}'))
        if [[ ${#containers[@]} -gt 1 ]]; then
            echo "Pod '$selected_pod' has multiple containers:"
            j=1
            for container in "${containers[@]}"; do
                echo "$j. $container"
                j=$((j+1))
            done
            read -p "Please enter the container number: " container_choice
            if [[ $container_choice -ge 1 && $container_choice -le ${#containers[@]} ]]; then
                selected_container=${containers[$((container_choice-1))]}
                echo "Connecting to container '$selected_container' in pod '$selected_pod'..."
                k exec -it $selected_pod -c $selected_container -- /bin/bash
            else
                echo "Invalid container selection."
            fi
        else
            # Only one container in the pod
            echo "Connecting to pod '$selected_pod'..."
            k exec -it $selected_pod -- /bin/bash
        fi
    else
        echo "Invalid selection."
    fi
}

function MENU_delete_pod {
    # Get all pods in the current namespace
    pods=($(k get pods --no-headers | awk '{print $1}'))

    # Check if there are any pods
    if [[ ${#pods[@]} -eq 0 ]]; then
        echo "No pods found in the current namespace."
        return
    fi

    echo "Available pods:"
    i=1
    for pod in "${pods[@]}"; do
        echo "$i. $pod"
        i=$((i+1))
    done

    read -p "Please enter the number of the pod to delete: " choice

    if [[ $choice -ge 1 && $choice -le ${#pods[@]} ]]; then
        selected_pod=${pods[$((choice-1))]}
        echo "Are you sure you want to delete pod '$selected_pod'? This action cannot be undone. (y/n)"
        read -p "Confirm deletion: " confirmation
        if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
            echo "Deleting pod '$selected_pod'..."
            k delete pod $selected_pod
            echo "Pod '$selected_pod' has been deleted."
        else
            echo "Deletion cancelled."
        fi
    else
        echo "Invalid selection."
    fi
}

function MENU_delete_metrics_infrastructure() {
    # Delete Grafana and Prometheus Helm releases
    h delete grafana --namespace default
    h delete prometheus --namespace default

    # Find and delete all pods with "prometheus" or "grafana" in their names
    k get pods -n default \
        | grep -E 'prometheus|grafana' \
        | awk '{print $1}' \
        | xargs -r k delete pod -n default

    # Uninstall Helm
    echo "Uninstalling Helm..."

    # Find the Helm binary path
    HELM_PATH=$(command -v helm)

    if [ -n "$HELM_PATH" ]; then
        echo "Helm binary found at $HELM_PATH"

        # Remove the Helm binary
        if [ -w "$HELM_PATH" ]; then
            rm "$HELM_PATH"
            echo "Helm binary removed."
        else
            sudo rm "$HELM_PATH"
            echo "Helm binary removed with sudo."
        fi

        # Remove Helm configuration and cache directories
        rm -rf ~/.helm
        rm -rf ~/.cache/helm
        echo "Helm configuration and cache directories removed."
    else
        echo "Helm binary not found. It may have already been uninstalled."
    fi
}

function MENU_get_database_connection_command() {
    external_ip=$(get_external_database_host)
    external_port=$(get_external_database_port)
    
    if [[ "$TF_VAR_kube_config_path" == "$kind_kube_config_path" ]]; then
        echo "FROM THE DEV CONTAINER -> psql -h host.docker.internal -p ${external_port} -U postgres -d postgres"
        echo "FROM THE HOST COMPUTER -> psql -h ${external_ip} -p ${external_port} -U postgres -d postgres"
    else
        echo "psql -h ${external_ip} -p ${external_port} -U postgres -d postgres"
    fi

    echo "password=${TF_VAR_postgres_password}"
}

function MENU_print_server_log {
    # Get the list of deployments and statefulsets dynamically
    resources=($(k get deployments,statefulsets -o jsonpath='{range .items[*]}{.kind}:{.metadata.name}{"\n"}{end}'))

    # Check if any resources were found
    if [[ ${#resources[@]} -eq 0 ]]; then
        echo "No deployments or statefulsets found."
        return
    fi

    # Print the list of resources
    echo "Which logs would you like to print?"
    for i in "${!resources[@]}"; do
        resource_info=(${resources[$i]//:/ }) # Split kind and name
        kind=${resource_info[0]}
        name=${resource_info[1]}
        echo "$((i + 1)). $kind: $name"
    done

    # Ask the user to input a value
    read -p "Please enter a number: " user_choice

    # Validate the input and call print_logs for the selected resource
    if [[ $user_choice -ge 1 && $user_choice -le ${#resources[@]} ]]; then
        selected_resource=(${resources[$((user_choice - 1))]//:/ }) # Split kind and name
        resource_kind=$(echo "${selected_resource[0]}" | tr '[:upper:]' '[:lower:]') # Convert kind to lowercase
        resource_name="${selected_resource[1]}"
        print_logs "$resource_kind" "$resource_name"
    else
        echo "Invalid selection. Please enter a number between 1 and ${#resources[@]}."
        MENU_print_server_log  # Retry the selection process
    fi
}

#!/usr/bin/env bash

function MENU_print_pod_log {
    # 1. Gather all distinct container names
    mapfile -t all_containers < <(k get pods \
        -o jsonpath="{range .items[*]}{range .spec.containers[*]}{.name}{'\n'}{end}{end}" \
        | sort -u)

    if [[ ${#all_containers[@]} -eq 0 ]]; then
        echo "No containers found in the cluster."
        return
    fi

    echo "Select a container name from the list:"
    for i in "${!all_containers[@]}"; do
        echo "$((i+1)). ${all_containers[$i]}"
    done

    read -p "Enter a number: " container_choice

    # Validate container choice
    if [[ $container_choice -lt 1 || $container_choice -gt ${#all_containers[@]} ]]; then
        echo "Invalid choice."
        MENU_print_pod_log
        return
    fi

    local chosen_container="${all_containers[$((container_choice-1))]}"

    # 2. Get the pods that contain the chosen container
    #    This jsonpath trick prints each podname:all-of-its-containers, then we filter by the chosen_container
    mapfile -t matching_pods < <(k get pods \
        -o jsonpath="{range .items[*]}{.metadata.name}{':'}{range .spec.containers[*]}{.name}{','}{end}{'\n'}{end}" \
        | grep -w "$chosen_container" \
        | cut -d ':' -f1)

    if [[ ${#matching_pods[@]} -eq 0 ]]; then
        echo "No pods found that contain container '$chosen_container'."
        return
    fi

    echo "Select a pod that includes container '$chosen_container':"
    for i in "${!matching_pods[@]}"; do
        echo "$((i+1)). ${matching_pods[$i]}"
    done

    read -p "Enter a number: " pod_choice

    # Validate pod choice
    if [[ $pod_choice -lt 1 || $pod_choice -gt ${#matching_pods[@]} ]]; then
        echo "Invalid choice."
        MENU_print_pod_log
        return
    fi

    local chosen_pod="${matching_pods[$((pod_choice-1))]}"

    # 3. List the containers within the chosen pod
    mapfile -t pod_containers < <(k get pod "$chosen_pod" \
        -o jsonpath="{range .spec.containers[*]}{.name}{'\n'}{end}")

    if [[ ${#pod_containers[@]} -eq 0 ]]; then
        echo "No containers found in pod '$chosen_pod' (unexpected)."
        return
    fi

    echo "Select one of the containers in pod '$chosen_pod' or choose 'All' to get logs from every container."
    for i in "${!pod_containers[@]}"; do
        echo "$((i+1)). ${pod_containers[$i]}"
    done
    echo "$(( ${#pod_containers[@]} + 1 )). All containers"

    read -p "Enter a number: " final_choice

    # Validate final choice
    if [[ $final_choice -lt 1 || $final_choice -gt $(( ${#pod_containers[@]} + 1 )) ]]; then
        echo "Invalid choice."
        MENU_print_pod_log
        return
    fi

    # If user picks "All"
    if [[ $final_choice -eq $(( ${#pod_containers[@]} + 1 )) ]]; then
        echo "Printing logs for ALL containers in pod: $chosen_pod"
        k logs "$chosen_pod" --all-containers=true
    else
        # Print logs for a specific container
        local final_container="${pod_containers[$((final_choice-1))]}"
        echo "Printing logs for pod: $chosen_pod, container: $final_container"
        k logs "$chosen_pod" -c "$final_container"
    fi
}


################################################################################
######## MENU ##################################################################
################################################################################

# This script allows you to either:
# 1. Pass a function name as an argument (in the format --function_name) to run a specific utility directly.
#    - Example: ./script.sh --MENU_print_server_log will run the function MENU_print_server_log.
# 2. If no argument is passed, the script will display a numbered menu listing all available functions (those prefixed with MENU_).
#    - You can select a function by entering its corresponding number.
# 
# The script works by:
# - Extracting all functions that are prefixed with MENU_.
# - If a function name is passed as an argument, it will attempt to match and execute the corresponding function.
# - If no argument is provided, it generates a menu of available functions, allowing the user to choose one by number.
# - Invalid input will prompt the user to enter a valid number from the menu.

# Extract the function names prefixed with MENU_
function_list=$(declare -F | awk '{print $3}' | grep '^MENU_')

# Check if a function was passed as an argument
if [[ $1 =~ ^-- ]]; then
    # Remove the '--' prefix to get the function name
    function_name="${1#--}"

    # Check if the function exists using grep
    if echo "$function_list" | grep -q "^MENU_$function_name$"; then
        # Run the function if it exists
        echo "Running $function_name..."
        MENU_$function_name
        exit 0
    else
        echo "Function MENU_$function_name not found."
        exit 1
    fi
fi

# If no function is passed, proceed with the menu prompt
echo "Which utility would you like to run? Please enter a value:"
i=1
for func in $function_list; do
    # Remove the MENU_ prefix for display purposes
    display_name=${func#MENU_}
    echo "$i. $display_name"
    functions_array[$i]=$func
    ((i++))
done

# Read user input
read -p "Enter the number of the utility to run: " choice

# Execute the selected function from the menu
selected_function=${functions_array[$choice]}

if [[ -n "$selected_function" ]]; then
    echo "Running ${selected_function#MENU_}.."
    $selected_function
else
    echo "Invalid selection. Please enter a valid number."
fi
