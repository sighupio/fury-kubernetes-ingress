# cert-manager Katalog

cert-manager is an automation tool for management and issuence of TLS certificates from various issuing resource in a Kubernetes native way. It ensures that certificates are valid and attempts to renew them before expiry. This package deploys cert-manager to be used with [Let's Encrypt](https://letsencrypt.org/) Certificate Authority


## Requirements

- Kubernetes >= `1.10.0`
- Kustomize >= `v1`
- [nginx-ingress]()


## Image repository and tag

* Cert Manager image: `quay.io/jetstack/cert-manager-controller:v0.5.0`
* Cert Manager repo: https://github.com/jetstack/cert-manager 
* Cert Manager documentation: https://cert-manager.readthedocs.io/en/latest/index.html


## Configuration

Fury distribution cert-manager is deployed with following configuration:

- Default issuer kind is ClusterIssuer
- Default issuer is letsenctypr


## Deployment

You can deploy Cert Manager by running following command in the root of the project:

`$ kustomize build | kubectl apply -f -`


## License

For license details please see [LICENSE](https://sighup.io/fury/license) 
