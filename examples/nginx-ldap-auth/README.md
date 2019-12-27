# Simple NGINX LDAP Auth

This example show how to deploy the NGINX LDAP auth package with the required configuration kubernetes secret.

1. Run furyctl to get packages: `$ furyctl install --dev`

2. Replace LDAP Data with yours in `ingress-nginx.yml` file. 

3. Run `make build` to see output of kustomize with your modifications.

4. Once you're satisfied with generated output run `make deploy` to deploy it on your cluster.
