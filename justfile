kubeconfigpath := "${HOME}/.kube/config"
talosconfigpath := "${HOME}/.talos/config"

default:
  just --list

save-cluster-configs:
    terraform -chdir={{justfile_directory()}}/terraform output -raw kubeconfig > {{kubeconfigpath}}
    terraform -chdir={{justfile_directory()}}/terraform output -raw talosconfig > {{talosconfigpath}}