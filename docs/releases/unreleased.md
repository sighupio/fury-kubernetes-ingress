# Ingress Core Module version 1.9.0

This release includes some improvements TBD

## Changelog

- Adds [cert-manager](../../katalog/cert-manager) dashboard.
- Fixes rbac permissions of the `nginx-ingress-role` when using dual-nginx, giving permissions to both ingresses (internal and external) to use the needed configmaps.

## Upgrade path

To upgrade this core module from `v1.8.0` to `v1.9.0`, you need to download this new version, then apply the
`kustomize` projects. No further action is required.

```bash
kustomize build katalog/cert-manager | kubectl apply -f -
kustomize build katalog/dual-nginx | kubectl apply -f -
```
