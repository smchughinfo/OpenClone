#!/bin/bash

source /vultr-api/registries.sh

login_to_container_registry() {
    echo "🔍 Starting container registry login process..."
    
    echo "📋 Getting registry information for 'openclone'..."
    registry=$(get_registry openclone)
    if [ $? -ne 0 ]; then
        echo "❌ Failed to get registry information"
        return 1
    fi
    echo "✅ Registry info retrieved successfully"
    
    echo "🔐 Extracting credentials..."
    username=$(echo "$registry" | jq -r '.root_user.username')
    password=$(echo "$registry" | jq -r '.root_user.password')
    
    echo "👤 Username: $username"
    echo "🔑 Password length: ${#password} characters"
    
    if [ -z "$username" ] || [ "$username" = "null" ]; then
        echo "❌ Username is empty or null"
        return 1
    fi
    
    if [ -z "$password" ] || [ "$password" = "null" ]; then
        echo "❌ Password is empty or null"
        return 1
    fi
    
    registry_url="${vultr_region}.vultrcr.com"
    echo "🌐 Registry URL: $registry_url"
    echo "📍 Vultr region: $vultr_region"
    
    echo "🔄 Attempting Docker login..."
    echo "$password" | docker login "$registry_url" -u "$username" --password-stdin
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully logged into container registry"
    else
        echo "❌ Docker login failed"
        return 1
    fi
}