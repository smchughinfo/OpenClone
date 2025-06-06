k() {
    skip_tls=""
    if [[ "$TF_VAR_kube_config_path" == "$kind_kube_config_path" ]]; then
        skip_tls="--insecure-skip-tls-verify=true"
    fi
    kubectl --kubeconfig="$TF_VAR_kube_config_path" $skip_tls "$@"
}

h() {
    helm --kubeconfig="$TF_VAR_kube_config_path" "$@"
}