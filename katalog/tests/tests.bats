#!/usr/bin/env bats

apply (){
  kustomize build $1 >&2
  kustomize build $1 | kubectl apply -f - 2>&3
}

@test "testing cert-manager apply" {
  apply katalog/cert-manager
}

@test "testing nginx apply" {
  apply katalog/nginx
}

@test "wait for apply to settle and dump state to dump.json" {
  max_retry=0
  echo "=====" $max_retry "=====" >&2
  while kubectl get pods --all-namespaces | grep -ie "\(Pending\|Error\|CrashLoop\|ContainerCreating\)" >&2
  do
    [ $max_retry -lt 24 ] || ( kubectl describe all --all-namespaces >&2 && return 1 )
    sleep 10 && echo "# waiting..." $max_retry >&3
    max_retry=$[ $max_retry + 1 ]
  done
}

@test "cleanup" {
  if [ -z "${LOCAL_DEV_ENV}" ];
  then
    skip
  fi
  for dir in cert-manager nginx
  do
    echo "# deleting katalog/$dir" >&3
    kustomize build katalog/$dir | kubectl delete -f - || true
    echo "# deleted katalog/$dir" >&3
  done
}
