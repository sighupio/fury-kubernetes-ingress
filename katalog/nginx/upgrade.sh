#!/bin/bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


kustomize build . > current-release.yaml

# Remember to change this version accordingly
VERSION=4.11.2

helm template ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace --version $VERSION --values MAINTENANCE.values.yml | yq -s '.kind + "-" + .metadata.name'

rm .yml
mv Certificate-ingress-nginx-root-cert.yml bases/configs
mv ClusterRole-ingress-nginx.yml bases/configs
mv ClusterRoleBinding-ingress-nginx.yml bases/configs
mv Issuer-ingress-nginx-root-issuer.yml bases/configs
mv Issuer-ingress-nginx-self-signed-issuer.yml bases/configs
mv PrometheusRule-ingress-nginx-controller.yml bases/configs
mv Role-ingress-nginx.yml bases/configs
mv RoleBinding-ingress-nginx.yml bases/configs
mv Service-ingress-nginx-controller-metrics.yml bases/configs
mv ServiceAccount-ingress-nginx.yml bases/configs
mv ServiceMonitor-ingress-nginx-controller.yml bases/configs

mv Certificate-ingress-nginx-admission.yml bases/controller
mv ConfigMap-ingress-nginx-controller.yml bases/controller
mv DaemonSet-ingress-nginx-controller.yml bases/controller
mv IngressClass-nginx.yml bases/controller
mv Service-ingress-nginx-controller-admission.yml bases/controller
mv Service-ingress-nginx-controller.yml bases/controller
mv ValidatingWebhookConfiguration-ingress-nginx-admission.yml bases/controller

