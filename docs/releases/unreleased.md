# Ingress Core Module version TBD

SIGHUP team maintains this module updated and tested. That is the main reason why we worked on this new release.
With the Kubernetes 1.20 release, it became the perfect time to start testing this module against this Kubernetes
release.

## Changelog
- Add missing namespace to cert-manager dashboard.

## Upgrade path

To upgrade this core module from `v1.8.2` to `v1.9.0`, you need to download this new version, then apply the
`kustomize` projects. No further action is required.

```bash
kustomize build katalog/cert-manager | kubectl apply -f -
# And
kustomize build katalog/forecastle | kubectl apply -f -
# And
kustomize build katalog/nginx | kubectl apply -f -
# Or
kustomize build katalog/dual-nginx | kubectl apply -f -
# Or
kustomize build katalog/nginx-gke | kubectl apply -f -
# Or
kustomize build katalog/nginx-ovh | kubectl apply -f -
```
