# Forecastle

<!-- <KFD-DOCS> -->

[Forecastle][forecastle-page] provides a handy dashboard to show all the applications running on Kubernetes exposed through an Ingress.

## Requirements

- Kubernetes >= `1.20.0`
- Kustomize >= `v3.5.3`

## Image repository and tag

- Forecastle image: `docker.io/stakater/forecastle:v1.0.103`
- Forecastle repo: [https://github.com/stakater/Forecastle](https://github.com/stakater/Forecastle)

## Configuration

Forecastle is deployed with the following configuration:

- watch every namespace for ingresses
- CRD support disabled
- unprivileged Pod
- hardened RBAC
- constrained resources

## Deployment

Forecastle can be deployed by running the following command at the root of the project:

```shell
kustomize build katalog/forecastle | kubectl apply -f -
```

### Usage

Once deployed, to have an ingress show up in the dashboard provided by Forecastle run:

```shell
kubectl annotate ingress <YOUR_INGRESS> "forecastle.stakater.com/expose=true" --overwrite
```

## Important notes

The `kubernetes.io/ingress.class` annotation is required by Forecastle to have the ingress displayed in the dashboard, therefore you need to add such annotation to all your ingresses even when using a single ingress controller.

<!-- Links -->
[forecastle-page]: https://github.com/stakater/Forecastle

<!-- </KFD-DOCS> -->
