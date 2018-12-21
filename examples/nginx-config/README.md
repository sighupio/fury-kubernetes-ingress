# Nginx Configuration

This example shows how to override Nginx configuration set via ConfigMap for Nginx Ingress Controller. For full list of configuration parameters please follow Nginx [documentation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/)

0. Run furyctl to get packages: `$ furyctl install --dev`

1. You can add/modify configuration options for Ingress Controller by modifying `nginx-config.yml` file. 

2. Run `make build` to see output of kustomize with your modifications.

3. Once you're satisfied with generated output run `make deploy` to deploy it on your cluster.
