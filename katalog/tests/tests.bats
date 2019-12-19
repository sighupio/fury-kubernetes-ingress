#!/usr/bin/env bats

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
  kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/master/katalog/prometheus-operator/crd-servicemonitor.yml
  kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/master/katalog/prometheus-operator/crd-rule.yml
}

@test "testing dual-nginx apply" {
  apply katalog/dual-nginx
}

@test "testing cert-manager apply" {
  apply katalog/cert-manager || wait_for_settlement 24
  apply katalog/cert-manager
}

@test "testing forecastle apply" {
  apply katalog/forecastle
}

@test "wait for apply to settle and dump state to dump.json" {
  wait_for_settlement 36
}
