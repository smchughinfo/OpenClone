#!/bin/bash

source /scripts/devcontainer-host/host-commands.sh
source /scripts/shell-helpers/aliases.sh

run_prometheus() {
    local launch_browser=${1:-"true"}
    local scrape_interval=${2:-"15s"} # Default scrape interval is 15 seconds

    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh 
    ./get_helm.sh
    h repo add prometheus-community https://prometheus-community.github.io/helm-charts
    h repo update

    # Check if the Prometheus release already exists
    if h ls --all --short | grep -q "^prometheus$"; then
        echo "Prometheus is already installed. Upgrading with new scrape interval."
        h upgrade prometheus prometheus-community/prometheus \
            --set server.global.scrape_interval=$scrape_interval
    else
        h install prometheus prometheus-community/prometheus \
            --set server.global.scrape_interval=$scrape_interval
    fi

    # Wait for the Prometheus server deployment to be ready
    echo "Waiting for Prometheus server deployment to be ready..."
    k rollout status deployment/prometheus-server --namespace default

    # Stop any existing port forwarding on port 9090
    echo "Stopping any existing port forwarding on port 9090..."
    lsof -ti tcp:9090 | xargs -r kill -9

    # Set up port forwarding after the deployment is ready
    echo "Port forwarding Prometheus service to local machine..."
    echo "Setting up port forwarding on 9090"
    k port-forward svc/prometheus-server 9090:80 >/dev/null 2>&1 &

    # Wait until Prometheus is accessible
    echo "Waiting for Prometheus to be available at http://127.0.0.1:9090. This may take several minutes..."
    until curl -s http://127.0.0.1:9090 >/dev/null; do
        echo "Still waiting..."
        sleep 5
    done
    echo "Prometheus is now available!"

    if [ "$launch_browser" = "true" ]; then
        run_host_command "Start http://127.0.0.1:9090"
    fi
}

# Grafana Provisioning Workflow:
# This setup automates the configuration and provisioning of Grafana dashboards and data sources 
# by leveraging Kubernetes ConfigMaps and Helm. The overall process involves creating three ConfigMaps: 
# one for data source configuration (`datasource-config`), one for dashboard provisioning configuration 
# (`dashboard-config`), and one for the actual dashboard JSON files (`grafana-dashboards`). These ConfigMaps 
# are mounted into specific paths within the Grafana container using `extraVolumes` and `extraVolumeMounts` 
# in the Helm chart installation command. The datasource configuration defines connections to external 
# services like Prometheus, mounted under `/etc/grafana/provisioning/datasources`. The dashboards provisioning 
# configuration tells Grafana where to look for dashboards (mounted at `/etc/grafana/provisioning/dashboards`) 
# and points to the directory `/var/lib/grafana/dashboards` where the JSON files are stored. 

# When Grafana starts, it reads the provisioning configurations from `/etc/grafana/provisioning/datasources` 
# and `/etc/grafana/provisioning/dashboards` to set up data sources and dashboards automatically. The JSON 
# dashboard definitions are loaded from `/var/lib/grafana/dashboards`, and Grafana provisions them into its 
# database, making them available in the UI. You will notice that dashboard-config.yaml and grafana-dashboards.yaml
# differ slightly from what you might see in grafana's documentation (https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards).
# This is because the files are written as a configmap. A configmap is a kubernetes concept that allows you to store
# files at the cluster level and then mount them into your pods. So the examples you see in grafana's documentation
# are wrapped in the configmaps's yaml. When you mount the configmap they get unwapped as dashboards.yaml, main-dashboard.json,
# etc. 
run_grafana() {
    local launch_browser=${1:-"true"}

    run_prometheus "false"

    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh

    h repo add grafana https://grafana.github.io/helm-charts
    h repo update

    # Apply Grafana ConfigMaps for data source and dashboard setup
    k apply -f /scripts/metrics/grafana/datasource-config.yaml
    k apply -f /scripts/metrics/grafana/dashboard-config.yaml
    k apply -f /scripts/metrics/grafana/grafana-dashboards.yaml

    # Check if Grafana release exists and install if not
    if h ls --all --short | grep -q "^grafana$"; then
        echo "Grafana is already installed. Skipping installation."
    else
        h install grafana grafana/grafana --namespace default \
            --set persistence.enabled=false \
            \
            --set extraVolumes[0].name=datasource-config \
            --set extraVolumes[0].configMap.name=datasource-config \
            --set extraVolumeMounts[0].name=datasource-config \
            --set extraVolumeMounts[0].mountPath=/etc/grafana/provisioning/datasources \
            \
            --set extraVolumes[1].name=dashboard-config \
            --set extraVolumes[1].configMap.name=dashboard-config \
            --set extraVolumeMounts[1].name=dashboard-config \
            --set extraVolumeMounts[1].mountPath=/etc/grafana/provisioning/dashboards \
            \
            --set extraVolumes[2].name=grafana-dashboards \
            --set extraVolumes[2].configMap.name=grafana-dashboards \
            --set extraVolumeMounts[2].name=grafana-dashboards \
            --set extraVolumeMounts[2].mountPath=/var/lib/grafana/dashboards
    fi

    # Wait for the Grafana deployment to be ready
    echo "Waiting for Grafana deployment to be ready..."
    k rollout status deployment/grafana --namespace default

    # Stop any existing port forwarding on port 3000
    echo "Stopping any existing port forwarding on port 3000..."
    lsof -ti tcp:3000 | xargs -r kill -9

    # Set up port forwarding after the deployment is ready
    echo "Port forwarding Grafana service to local machine..."
    k port-forward svc/grafana 3000:80 >/dev/null 2>&1 &

    # Wait until Grafana is accessible
    echo "Waiting for Grafana to be available at http://127.0.0.1:3000. This may take several minutes..."
    until curl -s http://127.0.0.1:3000 >/dev/null; do
        echo "Still waiting..."
        sleep 5
    done
    echo "Grafana is now available!"

    # Retrieve the admin password
    admin_password=$(k get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)

    # Escape single quotes in the admin_password for PowerShell
    escaped_admin_password=$(printf "%s" "$admin_password" | sed "s/'/''/g")

    # PowerShell command to copy password and display message
    ps_command="powershell -Command \"Set-Clipboard -Value '$escaped_admin_password'; [System.Windows.Forms.MessageBox]::Show('Username: admin | Password: $escaped_admin_password has been copied to clipboard', 'Grafana Access')\""

    if [ "$launch_browser" = "true" ]; then
        run_host_command "$ps_command"
        run_host_command "start http://localhost:3000"
    fi
}

# allow functions in this script to be called from terminal
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    source /scripts/shell-helpers/function-runner.sh
fi