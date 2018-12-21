# Default SSL Certificate for Nginx

This example shows how to add a default SSL certificate to configure Nginx as a catch-all server. TLS secret name should be passed with respective namespace as `<name-space>/<mycert-tls>`

0. Run furyctl to get packages: `$ furyctl install --dev`

1. Replace TLS secret with yours in `ingress-nginx.yml` file. 

2. Run `make build` to see output of kustomize with your modifications.

3. Once you're satisfied with generated output run `make deploy` to deploy it on your cluster.
