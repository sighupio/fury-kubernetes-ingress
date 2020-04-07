#!/usr/bin/env bats

load ./helper

apply (){
  kustomize build $1 >&2
  kustomize build $1 | kubectl apply -f -
}

wait_for_settlement (){
  max_retry=0
  echo "=====" $max_retry "=====" >&2
  while kubectl get pods --all-namespaces | grep -ie "\(Pending\|Error\|CrashLoop\|ContainerCreating\)" >&2
  do
    [ $max_retry -lt $1 ] || ( kubectl describe all --all-namespaces >&2 && return 1 )
    sleep 10 && echo "# waiting..." $max_retry >&3
    max_retry=$[ $max_retry + 1 ]
  done
}

@test "applying monitoring" {
  info
  kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.3.0/katalog/prometheus-operator/crd-servicemonitor.yml
  kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.3.0/katalog/prometheus-operator/crd-rule.yml
}

@test "testing dual-nginx apply" {
  info
  apply katalog/dual-nginx
}

@test "testing cert-manager apply" {
  info
  apply katalog/cert-manager || wait_for_settlement 24
  apply katalog/cert-manager
}

@test "testing forecastle apply" {
  info
  apply katalog/forecastle
}

@test "wait for apply to settle and dump state to dump.json" {
  info
  wait_for_settlement 36
}
