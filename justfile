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

# Start k3d cluster
start-cluster:
    k3d cluster start {{ name }}

# Stop k3d cluster
stop-cluster:
    k3d cluster stop {{ name }}

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

########################################################
# Kubectl

_kubectl *args:
    @kubectl config get-contexts k3d-{{ name }} >/dev/null 2>&1 || (echo "Error: k3d cluster '{{ name }}' not found. Run 'just create-cluster' first." && exit 1)
    kubectl {{ args }} \
        --namespace {{ name }} \
        --kubeconfig {{ kubeconfig }} \
        --context k3d-{{ name }}

# Get pods
pods:
    just _kubectl get pods

# Get services
svc:
    just _kubectl get svc

# Get PVCs
pvc:
    just _kubectl get pvc

# Get setup token from logs
setup-token:
    just _kubectl logs -l app.kubernetes.io/component=pangolin | grep -A 3 "SETUP TOKEN"

# Get Pangolin logs
logs-pangolin:
    just _kubectl logs -l app.kubernetes.io/component=pangolin

# Get Gerbil logs
logs-gerbil:
    just _kubectl logs -l app.kubernetes.io/component=gerbil -c gerbil

# Get Traefik logs
logs-traefik:
    just _kubectl logs -l app.kubernetes.io/component=gerbil -c traefik

# Get all logs
logs:
    just _kubectl logs -l app.kubernetes.io/component=pangolin
    @echo "---"
    just _kubectl logs -l app.kubernetes.io/component=gerbil -c gerbil
    @echo "---"
    just _kubectl logs -l app.kubernetes.io/component=gerbil -c traefik

# Describe pods
describe:
    just _kubectl describe pods
