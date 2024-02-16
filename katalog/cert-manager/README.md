# cert-manager

<!-- <KFD-DOCS> -->

cert-manager is an automation tool to manage and issue TLS certificates from various issuing resources in a Kubernetes native way. It ensures that certificates are valid and attempts to renew them before expiry.

This package deploys cert-manager to be used with [Let's Encrypt](https://letsencrypt.org/) as the Certificate Authority.

## Requirements

- Kubernetes `1.23` -> `1.28`
- Kustomize >= `v3.5.3`

## Image repository and tag

- Cert Manager image: `quay.io/jetstack/cert-manager-controller:v1.14.2`
- Cert Manager repo: [https://github.com/jetstack/cert-manager](https://github.com/jetstack/cert-manager)
- Cert Manager documentation: [https://cert-manager.io/docs/](https://cert-manager.io/docs/)

## Configuration

`cert-manager` is deployed with the following configuration:

- The default issuer kind is `ClusterIssuer`
- The default issuer is `letsencrypt`

## Deployment

To deploy the `cert-manager` package:

1. Add the package to your bases inside the `Furyfile.yml`:

```yaml
resources:
  - name: ingress/dual-nginx
    version: "v2.2.0"
  - name: ingress/cert-manager
    version: "v2.2.0"
```

2. Execute `furyctl legacy vendor -H` to download the packages

3. Inspect the download packages under `./vendor/katalog/ingress/cert-manager`.

4. Define a `kustomization.yaml` that includes the `./vendor/katalog/ingress/cert-manager` directory as resource.

```yaml
resources:
- ./vendor/katalog/ingress/cert-manager
```

For the `dual-nginx` you will need to patch the `ClusterIssuer` resource with the right ingress class:

```yml
---
patchesJson6902:
    - target:
          group: cert-manager.io
          version: v1
          kind: ClusterIssuer
          name: letsencrypt-staging
      path: patches/dual-nginx.yml
    - target:
          group: cert-manager.io
          version: v1
          kind: ClusterIssuer
          name: letsencrypt-prod
      path: patches/dual-nginx.yml
```

and in the `patches/dual-nginx.yml`:

```yml
---
- op: "replace"
  path: "/spec/acme/solvers/0/http01/ingress/class"
  value: "external"
```

5. Finally, execute the following command to deploy the package:

```shell
kustomize build . | kubectl apply -f -
```

<!-- </KFD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE).
