# NGINX Configuration

This example shows how to override NGINX configuration set via ConfigMap for NGINX Ingress Controller. For full list of
configuration parameters please follow NGINX
[documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/)

1. Run furyctl to get packages: `$ furyctl install --dev`

2. You can add/modify configuration options for Ingress Controller by modifying `nginx-config.yml` file.

3. Run `make build` to see output of kustomize with your modifications.

4. Once you're satisfied with generated output run `make deploy` to deploy it on your cluster.
