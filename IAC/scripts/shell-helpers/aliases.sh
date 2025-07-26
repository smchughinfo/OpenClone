k() {
    kubectl --kubeconfig="$TF_VAR_kube_config_path" "$@"
}

h() {
    helm --kubeconfig="$TF_VAR_kube_config_path" "$@"
}