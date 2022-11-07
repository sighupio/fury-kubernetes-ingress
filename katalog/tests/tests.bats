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

@test "testing dual-nginx apply" {
  info
  install() {
      apply katalog/dual-nginx
  }
  loop_it install 30 5
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

@test "prepare test ingresses" {
  info
  install() {
      kubectl apply -f katalog/tests/ingresses-tests.yaml
  }
  loop_it install 45 10
  status=${loop_it_result}
  [ "$status" -eq 0 ]
}

@test "Check that internal ingress controller is working" {
  info
  test() {
    http_code=$(curl "http://${INSTANCE_IP}:2080/internal" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "503" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Check that internal ingress is not working on external ingress controller" {
  info
  test() {
    http_code=$(curl "http://${INSTANCE_IP}:1080/internal" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Check that external ingress controller is working" {
  info
  test() {
    http_code=$(curl "http://${INSTANCE_IP}:1080/external" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "503" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}

@test "Check that external ingress is not working on internal ingress controller" {
  info
  test() {
    http_code=$(curl "http://${INSTANCE_IP}:2080/external" -s -o /dev/null -w "%{http_code}")
    if [ "${http_code}" -ne "404" ]; then return 1; fi
  }
  loop_it test 30 2
  status=${loop_it_result}
  [[ "$status" -eq 0 ]]
}