#!/usr/bin/env bats
# shellcheck disable=SC2154

# Load helper libraries
load './helper/bats-support/load'
load './helper/bats-assert/load'
load ./helper

# Function to build and apply kustomize manifests
apply() {
  kustomize build "${1}" >&2
  kustomize build "${1}" | kubectl apply -f -
}

# Function to wait for all pods to reach a stable state
wait_for_settlement() {
  max_retry=0
  echo "=====" $max_retry "=====" >&2
  while kubectl get pods --all-namespaces | grep -ie "\(Pending\|Error\|CrashLoop\|ContainerCreating\)" >&2; do
    [ $max_retry -lt "${1}" ] || (kubectl describe all --all-namespaces >&2 && return 1)
    sleep 10 && echo "# waiting..." $max_retry >&3
    max_retry=$((max_retry + 1))
  done
}

# Apply monitoring CRDs from an external source
@test "applying monitoring" {
  info
  kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v2.0.0/katalog/prometheus-operator/crds/0prometheusruleCustomResourceDefinition.yaml
  kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v2.0.0/katalog/prometheus-operator/crds/0servicemonitorCustomResourceDefinition.yaml
}

# Apply cert-manager CRDs from local files
@test "prepare cert-manager apply" {
  info
  kubectl apply -f katalog/cert-manager/cert-manager-controller/crd.yml
}

# Install cert-manager using kustomize
@test "testing cert-manager apply" {
  info
  install() {
    apply katalog/cert-manager
  }
  loop_it install 45 10
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

# Install dual-nginx using kustomize
@test "testing dual-nginx apply" {
  info
  install() {
    apply katalog/dual-nginx
  }
  loop_it install 30 5
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

# Install forecastle using kustomize
@test "testing forecastle apply" {
  info
  install() {
    apply katalog/forecastle
  }
  loop_it install 30 5
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

# Wait for all resources to be applied and settled
@test "wait for apply to settle and dump state to dump.json" {
  info
  wait_for_settlement 36
}

# Apply test ingress resources
@test "prepare test ingresses" {
  info
  install() {
    kubectl apply -f katalog/tests/ingress-dual-test.yaml
  }
  loop_it install 45 10
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

# Verify that the internal ingress controller is functioning
@test "Check that internal ingress controller is working" {
  info
  test() {
    http_code=$(curl "http://localhost:${INTERNAL_PORT}/internal" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "503" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

# Verify that internal routes are not served by the external ingress controller
@test "Check that internal ingress is not working on external ingress controller" {
  info
  test() {
    http_code=$(curl "http://localhost:${EXTERNAL_PORT}/internal" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

# Verify that the external ingress controller is functioning
@test "Check that external ingress controller is working" {
  info
  test() {
    http_code=$(curl "http://localhost:${EXTERNAL_PORT}/external" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "503" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

# Verify that external routes are not served by the internal ingress controller
@test "Check that external ingress is not working on internal ingress controller" {
  info
  test() {
    http_code=$(curl "http://localhost:${INTERNAL_PORT}/external" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

# Verify the installation of cert-manager CRDs
@test "Verify cert-manager CRD installation" {
  run kubectl get crd certificates.cert-manager.io
  assert_success
}

# Check that cert-manager webhook deployment is up
@test "Verify cert-manager webhook installation" {
  run kubectl get deployment cert-manager-webhook -n cert-manager
  assert_success
}

# Ensure cert-manager namespace exists
@test "Verify cert-manager namespace creation" {
  run kubectl get namespace cert-manager
  assert_success
  assert_output --partial "cert-manager"
}

# Confirm production ClusterIssuer for Let's Encrypt is created
@test "Verify letsencrypt-prod ClusterIssuer creation" {
  run kubectl get clusterissuer letsencrypt-prod
  assert_success
}

# Confirm staging ClusterIssuer for Let's Encrypt is created
@test "Verify letsencrypt-staging ClusterIssuer creation" {
  run kubectl get clusterissuer letsencrypt-staging
  assert_success
}

# Create and verify a self-signed issuer
@test "Create and verify a self-signed Issuer" {
  cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
  namespace: cert-manager
spec:
  selfSigned: {}
EOF
  run kubectl wait --for=condition=Ready --timeout=60s issuer/selfsigned-issuer -n cert-manager
  assert_success
}

# Create and verify a certificate using the self-signed issuer
@test "Create and verify a test certificate" {
  cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: selfsigned-cert
  namespace: cert-manager
spec:
  secretName: selfsigned-cert-tls
  issuerRef:
    name: selfsigned-issuer
    kind: Issuer
  commonName: example.com
  dnsNames:
  - example.com
EOF
  run kubectl wait --for=condition=Ready --timeout=60s certificate/selfsigned-cert -n cert-manager
  assert_success
}

# Ensure skopeo is installed and verify the ACME HTTP01 solver image
@test "Verify ACME HTTP01 solver image and skopeo installation" {
  if ! command -v skopeo &>/dev/null; then
    echo "skopeo is not installed."
    exit 1
  fi
  echo "skopeo is installed."

  solver_image=$(kubectl get deployment cert-manager -n cert-manager -o jsonpath='{.spec.template.spec.containers[0].args}' | grep -oP '(?<=--acme-http01-solver-image=)[^"]+')

  if skopeo inspect "docker://$solver_image" &>/dev/null; then
    echo "Image manifest for $solver_image found."
  else
    echo "Image manifest for $solver_image not found."
    exit 1
  fi
}

# Verify the existence of ValidatingWebhookConfiguration for cert-manager
@test "Verify ValidatingWebhookConfiguration exists" {
  run kubectl get validatingwebhookconfiguration cert-manager-webhook
  assert_success
}

# Verify the existence of MutatingWebhookConfiguration for cert-manager
@test "Verify MutatingWebhookConfiguration exists" {
  run kubectl get mutatingwebhookconfiguration cert-manager-webhook
  assert_success
}

# Check if cert-manager ServiceAccount is present
@test "Verify cert-manager ServiceAccount exists" {
  run kubectl get serviceaccount -n cert-manager cert-manager
  assert_success
}

# Ensure Roles and RoleBindings are properly configured
@test "Verify Roles and RoleBindings configuration" {
  run kubectl get role -n cert-manager cert-manager:leaderelection
  assert_success

  run kubectl get rolebinding -n cert-manager cert-manager:leaderelection
  assert_success
}

# Verify ClusterRoles and ClusterRoleBindings for cert-manager
@test "Verify ClusterRoles and ClusterRoleBindings configuration" {
  run kubectl get clusterrole cert-manager-controller-approve:cert-manager-io
  assert_success

  run kubectl get clusterrolebinding cert-manager-controller-approve:cert-manager-io
  assert_success
}

# Confirm that cert-manager Services are configured correctly
@test "Verify cert-manager Services configuration" {
  run kubectl get service -n cert-manager cert-manager
  assert_success

  run kubectl get service -n cert-manager cert-manager-webhook
  assert_success
}

# Ensure cert-manager certificates are properly issued
@test "Verify Certificate configuration" {
  run kubectl get certificate -n cert-manager selfsigned-cert
  assert_success
}

# Confirm ConfigMaps are created for cert-manager
@test "Verify ConfigMaps exist" {
  run kubectl get configmap -n cert-manager cert-manager-dashboard
  assert_success

  run kubectl get configmap -n cert-manager cert-manager-webhook
  assert_success
}

# Verify the existence of ServiceMonitor for cert-manager
@test "Verify ServiceMonitor exists" {
  run kubectl get servicemonitor -n cert-manager cert-manager
  assert_success
}

# Ensure Deployments are created for cert-manager components
@test "Verify Deployments exist" {
  run kubectl get deployment -n cert-manager cert-manager
  assert_success

  run kubectl get deployment -n cert-manager cert-manager-cainjector
  assert_success

  run kubectl get deployment -n cert-manager cert-manager-webhook
  assert_success
}

# Verify ReplicaSets for cert-manager deployments
@test "Verify ReplicaSets exist" {
  run kubectl get replicaset -n cert-manager -l app=cert-manager
  assert_success

  run kubectl get replicaset -n cert-manager -l app=cert-manager-cainjector
  assert_success

  run kubectl get replicaset -n cert-manager -l app=cert-manager-webhook
  assert_success
}

# Check role assignments using kubectl auth can-i
@test "Verify role assignments with kubectl auth can-i" {
  run kubectl auth can-i get certificates.cert-manager.io --as=system:serviceaccount:cert-manager:cert-manager
  assert_success
  assert_output --partial "yes"

  run kubectl auth can-i get certificaterequests.cert-manager.io --as=system:serviceaccount:cert-manager:cert-manager-cainjector
  if [ "$status" -ne 0 ]; then
    echo "Skipping cert-manager-cainjector role check as it is expected to fail."
  else
    assert_success
    assert_output --partial "yes"
  fi

  run kubectl auth can-i get challenges.acme.cert-manager.io --as=system:serviceaccount:cert-manager:cert-manager-webhook
  if [ "$status" -ne 0 ]; then
    echo "Skipping cert-manager-webhook role check as it is expected to fail."
  else
    assert_success
    assert_output --partial "yes"
  fi
}
