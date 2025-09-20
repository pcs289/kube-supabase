#!/usr/bin/env bash

COMMAND=$1
shift 1
COMMAND_TARGET=$@

DEFAULT_ENV="production"

TF_PATH="terraform"
TF_MODULE_PATH="${TF_PATH}/modules"
TF_ENV_PATH="${TF_PATH}/environments/${DEFAULT_ENV}"

MANIFESTS_PATH="manifests"
MANIFESTS_CHARTS_PATH="${MANIFESTS_PATH}/charts"
MANIFESTS_ENV_PATH="${MANIFESTS_PATH}/environments/${DEFAULT_ENV}"

CLUSTER_NAME="${DEFAULT_ENV}-cluster"
KEY_NAME="${DEFAULT_ENV}-secret-store-key"
SECRET_ID="${DEFAULT_ENV}-supabase-jwt"
APP_NAME="supabase"
APP_NAMESPACE="supabase"


check_command() {
  local cmd=$1
  local url=$2
  shift 2
  local params=$@

  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "❌ $cmd not found. Please install it: $url"
    exit 1
  else
    echo "✅ $cmd is installed: $($cmd $params | head -n 1)"
  fi
}

cleanup() {

    echo "💥 Nuking all Karpenter + cluster resources..."

    # 1. Delete all Karpenter CRDs and resources if they exist
    KARPENTER_CRDS=$(kubectl get crd -o name 2>/dev/null | grep karpenter || true)

    if [[ -n "$KARPENTER_CRDS" ]]; then
        echo "👉 Found Karpenter CRDs:"
        echo "$KARPENTER_CRDS"

        for crd in $KARPENTER_CRDS; do
            kind=$(echo "$crd" | cut -d'/' -f2 | sed 's/\.karpenter.*//')
            echo "💣 Deleting all $kind resources..."
            kubectl delete "$kind" --all --ignore-not-found=true || true

            echo "💣 Removing finalizers from $kind resources (if any)..."
            kubectl get "$kind" -o name --ignore-not-found=true 2>/dev/null | while read -r r; do
                echo "💣 Patching Finalizers $r"
                kubectl patch "$r" --type merge -p '{"metadata":{"finalizers":null}}' || true
            done
        done

        echo "💣 Deleting Karpenter CRDs themselves..."
        kubectl delete $KARPENTER_CRDS --ignore-not-found=true || true
    else
        echo "✅ No Karpenter CRDs found."
    fi

    # 2. Delete stuck Nodes
    echo "👉 Checking for stuck Nodes..."
    kubectl get nodes --no-headers 2>/dev/null | awk '{print $1}' | while read -r node; do
        echo "💣 Force deleting node: $node"
        kubectl delete node "$node" --force --grace-period=0 || true
    done

    # 3. Optionally nuke all remaining cluster-scoped resources (except system namespaces)
    echo "👉 Cleaning up leftover non-system resources..."
    NAMESPACES=$(kubectl get ns --no-headers | awk '{print $1}' | grep -vE 'kube-system|kube-public|kube-node-lease|default')

    for ns in $NAMESPACES; do
        echo "💣 Deleting all resources in namespace: $ns"
        kubectl delete all --all -n "$ns" --ignore-not-found=true || true

        echo "💣 Removing finalizers in namespace: $ns"
        kubectl get all -n "$ns" -o name 2>/dev/null | while read -r r; do
            echo "💣 Patching Finalizers $r"
            kubectl patch "$r" -n "$ns" --type merge -p '{"metadata":{"finalizers":null}}' || true
        done
    done

    echo "✅ Cluster Cleanup complete!"

}

case "$COMMAND" in
    "prerequisites")
        echo "🔍 Checking required tools..."
        check_command aws "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html" --version
        check_command terraform "https://developer.hashicorp.com/terraform/downloads" version
        check_command terraform-docs "https://terraform-docs.io/user-guide/installation/" version
        check_command helm "https://helm.sh/docs/intro/install/" version
        check_command kubectl "https://kubernetes.io/docs/tasks/tools/" version --client
        echo "🚀 All prerequisites are installed and configured."
        ;;
    "fmt")
        echo "🎨 Succesfully formatted all files"
        terraform fmt -recursive "${TF_MODULE_PATH}"
        terraform fmt -recursive "${TF_ENV_PATH}"
        ;;
    "init")
        echo "⚙️ Initializing ${DEFAULT_ENV} environment"
        terraform -chdir="${TF_ENV_PATH}" init
        ;;
    "validate")
        echo "🧪 Validating code for ${DEFAULT_ENV} environment"
        terraform -chdir="${TF_ENV_PATH}" validate
        ;;
    "plan")
        if [[ "$COMMAND_TARGET" == "" ]]; then
            echo "📋 Planning changes. environment: ${DEFAULT_ENV}"
            terraform -chdir="${TF_ENV_PATH}" plan ;
        else
            echo "📋 Planning changes. environment: ${DEFAULT_ENV}, target ${COMMAND_TARGET}"
            terraform -chdir="${TF_ENV_PATH}" plan -target=${COMMAND_TARGET} ;
        fi
        ;;
    "import")
        if [[ ! "$COMMAND_TARGET" == "" ]]; then
            echo "📋 Importing resource. environment: ${DEFAULT_ENV}, target ${COMMAND_TARGET}"
            terraform -chdir="${TF_ENV_PATH}" import ${COMMAND_TARGET} ;
        fi
        ;;
    "apply")
        if [[ "$COMMAND_TARGET" == "" ]]; then
            echo "🚀 Applying changes. environment: ${DEFAULT_ENV}"
            terraform -chdir="${TF_ENV_PATH}" apply --auto-approve ;
        else
            echo "🚀 Applying changes. environment: ${DEFAULT_ENV}, target ${COMMAND_TARGET}"
            terraform -chdir="${TF_ENV_PATH}" apply -target=${COMMAND_TARGET} --auto-approve ;
        fi
        ;;
    "destroy")
        if [[ "$COMMAND_TARGET" == "" ]]; then
            echo "💣 Destroying changes. environment: ${DEFAULT_ENV}"
            terraform -chdir="${TF_ENV_PATH}" destroy ;
        else
            echo "💣 Destroying changes. environment: ${DEFAULT_ENV}, target ${COMMAND_TARGET}"
            terraform -chdir="${TF_ENV_PATH}" destroy -target=${COMMAND_TARGET}
            # if [[ "$COMMAND_TARGET" == "module.helm_base" ]]; then
            #     cleanup
            # fi;
        fi
        ;;
    "provision")
        ./config.sh init
        ./config.sh apply module.vpc
        ./config.sh apply module.eks
        ./config.sh apply module.helm_base
        ./config.sh apply module.secret_store
        ./config.sh apply module.bucket
        ./config.sh apply module.rds
        ;;
    "tear-down")
        ./config.sh destroy module.rds
        ./config.sh destroy module.bucket
        ./config.sh destroy module.secret_store
        ./config.sh destroy module.helm_base
        ./config.sh destroy module.eks
        ./config.sh destroy module.vpc

        ;;
    "kubeconfig")
        echo "👉 Updating KubeConfig for cluster ${CLUSTER_NAME}"
        aws eks update-kubeconfig --name "${CLUSTER_NAME}"
        if kubectl cluster-info >/dev/null 2>&1; then
            echo "✅ kubeconfig is configured and cluster is reachable."
        else
            echo "❌ kubeconfig is not configured or cluster is not reachable."
            exit 1
        fi
        ;;
    "debug")
        echo "🚀 Debugging Cluster: ${CLUSTER_NAME}, environment: ${DEFAULT_ENV}"
        kubectl run --image=alpine -it debug --rm -- sh -c "apk add --update --no-cache --quiet postgresql-client && sh"
        ;;
    "template")
        echo "🚀 Templating app: ${APP_NAME}, environment: ${DEFAULT_ENV}"
        helm template "./${MANIFESTS_CHARTS_PATH}/${APP_NAME}" --values="./${MANIFESTS_ENV_PATH}/${APP_NAME}.yaml"
        ;;
    "deploy")
        echo "🚀 Deploying app: ${APP_NAME}, environment: ${DEFAULT_ENV}"
        helm upgrade --install "${APP_NAME}" "./${MANIFESTS_CHARTS_PATH}/${APP_NAME}" --values="./${MANIFESTS_ENV_PATH}/${APP_NAME}.yaml" --create-namespace --namespace="${APP_NAMESPACE}" --history-max 5
        echo "🚀 Deploying app: haproxy, environment: ${DEFAULT_ENV}"
        kubectl apply -f "./${MANIFESTS_ENV_PATH}/haproxy"
        ;;
    "cleanup")
        cleanup
        ;;
    "smoke")
        echo "🚬 Smoke testing app: ${APP_NAME}, environment: ${DEFAULT_ENV}"
        # echo "Portforward supabase-kong from Cluster"
        # kubectl port-forward svc/supabase-supabase-kong 8000:8000 -n supabase &
        # pf_pid=$!
        # sleep 2
        echo "Getting anonKey from SecretsManager"
        TOKEN=$(aws secretsmanager get-secret-value --secret-id ${SECRET_ID} | jq -r '.SecretString | fromjson | .anonKey')
        echo "Trying Supabase access with anonKey at /rest/v1 endpoint"
        curl -i -H "Authorization: Bearer ${TOKEN}" -H "api_key: ${TOKEN}" localhost:8000/rest/v1
        # kill -n $pf_id
        # wait $pf_pid 2>/dev/null
        ;;
    "encrypt")
        echo "🔒 Encrypting Secret for ${DEFAULT_ENV}"
        if [[ "$COMMAND_TARGET" == "" ]]; then
            echo -n "Secret: " && \
            read -s secret && \
            secret64=$(echo -n "$secret" | base64) && \
            aws kms encrypt --key-id=alias/"${KEY_NAME}" --plaintext "$secret64" --output text --query CiphertextBlob ;
        fi
        ;;
    "decrypt")
        echo "🔓 Decrypting Secret for ${DEFAULT_ENV}"
        if [[ "$COMMAND_TARGET" == "" ]]; then
            echo -n "Secret: " && \
            read -s secret && \
            aws kms decrypt --key-id=alias/"${KEY_NAME}" --ciphertext-blob "$secret" --output text --query Plaintext | base64 -d ;
        fi
        ;;
    *)
        echo "❌ Unknown Command: ${COMMAND}" ;;
esac

exit 0
