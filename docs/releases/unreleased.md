# Ingress Core Module version 1.9.0

This release includes some improvements TBD

## Changelog

- Adds [cert-manager](../../katalog/cert-manager) dashboard.


## Upgrade path

To upgrade this core module from `v1.8.0` to `v1.9.0`, you need to download this new version, then apply the
`kustomize` projects. No further action is required.

```bash
kustomize build katalog/cert-manager | kubectl apply -f -
```
