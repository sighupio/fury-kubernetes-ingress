# cert-manager

cert-manager is an automation tool for management and issuance of TLS
certificates from various issuing resource in a Kubernetes native way. It
ensures that certificates are valid and attempts to renew them before expiry.

This package deploys cert-manager to be used with [Let's
Encrypt](https://letsencrypt.org/) Certificate Authority.

## Requirements

-   Kubernetes >= `1.10.0`
-   Kustomize >= `v1`
-   [nginx-ingress](../nginx)

## Image repository and tag

-   Cert Manager image: `quay.io/jetstack/cert-manager-controller:v0.14.1`
-   Cert Manager repo: https://github.com/jetstack/cert-manager
-   Cert Manager documentation: https://cert-manager.io/docs/

## Configuration

Fury distribution cert-manager is deployed with the following configuration:

-   Default issuer kind is ClusterIssuer
-   Default issuer is letsencrypt

## Deployment

The deployment is the following, but keep in mind that, depending of `nginx` or `dual-nginx` you need to specify the class name accordingly.
To do that you need to patch the ClusterIssuer resource in order to keep it synced with your specific deployment.
So before proceed to the build and apply, you should provide a patchesJson6902 like the following:

```yml
patchesJson6902:
    - target:
          group: certmanager.k8s.io
          version: v1alpha1
          kind: ClusterIssuer
          name: letsencrypt-staging
      path: patches/dual-nginx.yml
    - target:
          group: certmanager.k8s.io
          version: v1alpha1
          kind: ClusterIssuer
          name: letsencrypt-prod
      path: patches/dual-nginx.yml
```

and under the `patches/dual-nginx.yml`:

```yml
---
- op: "replace"
  path: "/spec/acme/solvers/0/http01/ingress/class"
  value: "external"
```

this is only needed when you'll use the the `dual-nginx` because the default is the `nginx` single node

Once do that, you just need to hit:

```shell
$ kustomize build | kubectl apply -f -
```

## License

For license details please see [LICENSE](../../LICENSE).
