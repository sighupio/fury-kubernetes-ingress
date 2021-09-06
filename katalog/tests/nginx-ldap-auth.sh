#!/usr/bin/env bats
# Copyright (c) 2020 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# shellcheck disable=SC2154

load ./helper

@test "Ensure ingress controller" {
    info
    ensure_ingress(){
        kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.13.0-rc/katalog/prometheus-operator/crd-servicemonitor.yml
        kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.13.0-rc/katalog/prometheus-operator/crd-rule.yml
        apply katalog/dual-nginx
    }
    run ensure_ingress
    [ "$status" -eq 0 ]
}

@test "Wait for ingress controller" {
    info
    test(){
        status=$(kubectl get pods -n ingress-nginx -l app=ingress,type=external -o jsonpath="{.items[*].status.phase}")
        if [ "${status}" != "Running" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Check Ingress controller is ready" {
    info
    test() {
        kubectl get pods -n ingress-nginx -l app=ingress,type=external -o json | jq '.items[].status.containerStatuses[].ready' | uniq | grep -q true
    }
    loop_it test 60 10
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Setup httpbin demo project" {
    info
    setup_demo(){
        kubectl create ns demo-nginx-ldap-auth --dry-run -o yaml | kubectl apply -f -
        kubectl apply -f katalog/tests/nginx-ldap-auth/httpbin.yaml -n demo-nginx-ldap-auth
    }
    run setup_demo
    [ "$status" -eq 0 ]
}

@test "Test no-auth httpbin ingress demo project" {
    info
    test(){
        http_code=$(curl -H "Host: ${INSTANCE_IP//./-}.nip.io" "http://${INSTANCE_IP}:${CLUSTER_NAME}80/get" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "200" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Deploy example ldap instance" {
    info
    setup_ldap(){
        kubectl create ns demo-ldap
        kubectl create configmap ldap-ldif --from-file=sighup.io.ldif=katalog/tests/nginx-ldap-auth/sighup.io-users.ldif  -n demo-ldap --dry-run -o yaml |kubectl apply -f -
        kubectl apply -f katalog/tests/nginx-ldap-auth/ldap-server.yaml -n demo-ldap
    }
    run setup_ldap
    [ "$status" -eq 0 ]
}

@test "Deploy nginx-ldap-auth" {
    info
    setup_nginx_ldap_auth() {
        kubectl create secret generic nginx-ldap-auth --from-file=config.yaml=katalog/tests/nginx-ldap-auth/nginx-ldap-auth-config.yaml -n ingress-nginx
        apply katalog/nginx-ldap-auth
    }
    run setup_nginx_ldap_auth
    [ "$status" -eq 0 ]
}

@test "Wait for example ldap instance" {
    info
    test(){
        status=$(kubectl get pods -n demo-ldap -l app=ldap-server -o jsonpath="{.items[*].status.phase}")
        if [ "${status}" != "Running" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Wait for nginx-ldap-auth" {
    info
    test(){
        status=$(kubectl get pods -n ingress-nginx -l app=nginx-ldap-auth -o jsonpath="{.items[*].status.phase}")
        if [ "${status}" != "Running" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Securize ingress definition" {
    info
    secure_it(){
        kubectl annotate ingress secured-nip-io "nginx.ingress.kubernetes.io/auth-url=http://nginx-ldap-auth.ingress-nginx.svc.cluster.local" -n demo-nginx-ldap-auth --overwrite
    }
    run secure_it
    [ "$status" -eq 0 ]
}

@test "Users. Test no-auth secured httpbin ingress demo project" {
    info
    test(){
        http_code=$(curl -H "Host: ${INSTANCE_IP//./-}.nip.io" "http://${INSTANCE_IP}:${CLUSTER_NAME}80/get" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "401" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Users. Test auth httpbin secured ingress demo project" {
    info
    test(){
        http_code=$(curl -u angel:angel -H "Host: ${INSTANCE_IP//./-}.nip.io" "http://${INSTANCE_IP}:${CLUSTER_NAME}80/get" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "200" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Users. Test auth (no authorized) httpbin secured ingress demo project" {
    info
    test(){
        http_code=$(curl -u ramiro:ramiro -H "Host: ${INSTANCE_IP//./-}.nip.io" "http://${INSTANCE_IP}:${CLUSTER_NAME}80/get" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "401" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

# Tests with another ldap tree structure (with groups)
@test "Groups. Deploy example ldap instance" {
    info
    setup_ldap(){
        kubectl create configmap ldap-ldif --from-file=sighup.io.ldif=katalog/tests/nginx-ldap-auth/sighup.io-groups.ldif  -n demo-ldap --dry-run -o yaml |kubectl apply -f -
        kubectl rollout restart deploy/ldap-server -n demo-ldap
    }
    run setup_ldap
    [ "$status" -eq 0 ]
}

@test "Groups. Deploy nginx-ldap-auth" {
    info
    setup_nginx_ldap_auth() {
        kubectl create secret generic nginx-ldap-auth --from-file=config.yaml=katalog/tests/nginx-ldap-auth/nginx-ldap-auth-config-groups.yaml -n ingress-nginx --dry-run -o yaml |kubectl apply -f -
        kubectl rollout restart deploy/nginx-ldap-auth  -n ingress-nginx
    }
    run setup_nginx_ldap_auth
    [ "$status" -eq 0 ]
}

@test "Groups. Wait for example ldap instance" {
    info
    test(){
        status=$(kubectl get pods -n demo-ldap -l app=ldap-server -o jsonpath="{.items[*].status.phase}")
        if [ "${status}" != "Running" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Groups. Wait for nginx-ldap-auth" {
    info
    test(){
        status=$(kubectl get pods -n ingress-nginx -l app=nginx-ldap-auth -o jsonpath="{.items[*].status.phase}")
        if [ "${status}" != "Running" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Groups. Test no-auth secured httpbin ingress demo project" {
    info
    test(){
        http_code=$(curl -H "Host: ${INSTANCE_IP//./-}.nip.io" "http://${INSTANCE_IP}:${CLUSTER_NAME}80/get" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "401" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Groups. Test auth httpbin secured ingress demo project" {
    info
    test(){
        http_code=$(curl -u jacopo:admin -H "Host: ${INSTANCE_IP//./-}.nip.io" "http://${INSTANCE_IP}:${CLUSTER_NAME}80/get" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "200" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Groups. Test auth (no authorized) httpbin secured ingress demo project" {
    info
    test(){
        http_code=$(curl -u angel:angel -H "Host: ${INSTANCE_IP//./-}.nip.io" "http://${INSTANCE_IP}:${CLUSTER_NAME}80/get" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "401" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Groups. Deploy ldap-protected registry" {
    info
    test(){
        kubectl apply -f katalog/tests/nginx-ldap-auth/ldap-registry.yaml -n demo-ldap
    }
    run test
    [ "$status" -eq 0 ]
}

@test "Groups. Wait for ldap-protected registry" {
    info
    test(){
        status=$(kubectl get pods -n demo-ldap -l run=registry -o jsonpath="{.items[*].status.phase}")
        if [ "${status}" != "Running" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Groups. Test auth registry protected" {
    info
    test(){
        http_code=$(curl -u jacopo:admin -H "Host: registry.local" "http://${INSTANCE_IP}:${CLUSTER_NAME}80/v2/" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "200" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Groups. Test auth (no authorized) registry protected" {
    info
    test(){
        http_code=$(curl -u angel:angel -H "Host: registry.local" "http://${INSTANCE_IP}:${CLUSTER_NAME}80/v2/" -s -o /dev/null -w "%{http_code}")
        if [ "${http_code}" -ne "401" ]; then return 1; fi
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}

@test "Rollback httpbin demo project" {
    info
    destroy_demo(){
        kubectl delete ns demo-nginx-ldap-auth
        kubectl delete ns demo-ldap
        kubectl delete secret nginx-ldap-auth -n ingress-nginx
        delete katalog/nginx-ldap-auth
    }
    run destroy_demo
    [ "$status" -eq 0 ]
}
