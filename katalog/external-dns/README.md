# ExternalDNS package

<!-- <KFD-DOCS> -->

ExternalDNS synchronizes exposed Kubernetes Services and Ingresses with DNS providers.

## Requirements

- Kubernetes >= `1.19.0`
- Kustomize = `v3.5.3`

## Image repository and tag

- ExternalDNS image: `k8s.gcr.io/external-dns/external-dns:v0.13.2`
- ExternalDNS repo: [https://github.com/kubernetes-sigs/external-dns](https://github.com/kubernetes-sigs/external-dns)

## Deployment

This package provides two deployments of external-dns, one for "private" records and one for "public" records. The only thing that differs between the two packages is the
suffix used on kustomize to generate all the resources.

The package itself cannot be used without patches, and in this module we provide terraform modules to generate the required cloud resources and kustomize patches.

You can deploy ExternalDNS in your cluster by including the package in your kustomize project:

`kustomization.yaml` file extract:
```yaml
...

resources:
  - katalog/external-dns/private
  - katalog/external-dns/public

...
```

Refer to the Terraform module [aws-eternal-dns](../../modules/aws-external-dns) to create the
IAM role and the required kustomize patches automatically. For now the only supported cloud provider is AWS with Route53.

If still you want to create everything manually without using our Terraform Module, you need to patch the service accountas follows:

`sa-patch.yaml`
```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789123:role/your-role-name-public
  name: external-dns-public
  namespace: ingress-nginx
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789123:role/your-role-name-private
  name: external-dns-private
  namespace: ingress-nginx
```

and then add on the `kustomization.yaml` file the patches:

`kustomization.yaml` file extract:
```yaml
...

patchesStrategicMerge:
  - sa-patch.yaml

...
```

You can then apply your kustomize project by running the following command:

```bash
kustomize build | kubectl apply -f -
```

<!-- </KFD-DOCS> -->

## License

For license details please see [LICENSE](../../LICENSE)
