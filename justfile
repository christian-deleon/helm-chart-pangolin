name := "pangolin"
helm_path := "./"
k3d_config := "k3d.yaml"
kubeconfig := "~/.kube/config"

# List all commands
list:
    just --list --unsorted

########################################################
# K3d

# Create k3d cluster
create-cluster:
    k3d cluster create {{ name }} --config {{ k3d_config }}

# Delete k3d cluster
delete-cluster:
    k3d cluster delete {{ name }}

########################################################
# Helm

_helm *args:
    helm {{ args }} \
        --namespace {{ name }} \
        --kubeconfig {{ kubeconfig }} \
        --kube-context k3d-{{ name }}

# Install chart
install:
    just _helm upgrade \
        --install {{ name }} {{ helm_path }} \
        --create-namespace \
        --values {{ helm_path }}values.yaml \
        --values {{ helm_path }}values.dev.yaml

# Uninstall chart
uninstall:
    just _helm uninstall {{ name }}
