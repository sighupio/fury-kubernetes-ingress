#!/usr/bin/env bats
# shellcheck disable=SC2154

load ./helper

apply (){
  kustomize build "${1}" >&2
  kustomize build "${1}" | kubectl apply -f -
}

wait_for_settlement (){
  max_retry=0
  echo "=====" $max_retry "=====" >&2
  while kubectl get pods --all-namespaces | grep -ie "\(Pending\|Error\|CrashLoop\|ContainerCreating\)" >&2
  do
    [ $max_retry -lt "${1}" ] || ( kubectl describe all --all-namespaces >&2 && return 1 )
    sleep 10 && echo "# waiting..." $max_retry >&3
    max_retry=$(( max_retry + 1 ))
  done
}

@test "applying monitoring" {
  info
  kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v2.0.0/katalog/prometheus-operator/crds/0prometheusruleCustomResourceDefinition.yaml
  kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v2.0.0/katalog/prometheus-operator/crds/0servicemonitorCustomResourceDefinition.yaml
}

@test "testing dual-nginx apply" {
  info
  install() {
      apply katalog/dual-nginx
  }
  loop_it install 30 5
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "prepare cert-manager apply" {
  info
  kubectl apply -f katalog/cert-manager/cert-manager-controller/crd.yml
}

@test "testing cert-manager apply" {
  info
  install() {
      apply katalog/cert-manager
  }
  loop_it install 45 10
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "testing forecastle apply" {
    info
    install() {
      apply katalog/forecastle
  }
  loop_it install 30 5
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "wait for apply to settle and dump state to dump.json" {
  info
  wait_for_settlement 36
}
