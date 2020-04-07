# Forecastle
[Forecastle](https://github.com/stakater/Forecastle) provides an handy dashboard
to show all the applications running on Kubernetes exposed through an Ingress.

## Requirements
- Kubernetes >= `1.14.0`
- Kustomize >= `v3`


## Image repository and tag
- Forecastle image: `docker.io/stakater/forecastle:v1.0.42`
- Forecastl repo: https://github.com/stakater/Forecastle

## Configuration
Forecastle is deployed with the following configuration:
- watch every namespace for ingresses
- CRD support disabled
- unprivileged Pod
- hardened RBAC
- constrained resources

## Deployment
Forecastle can be deployed by running the following command in the root of the
project:
```shell
kustomize build katalog/forecastl | kubectl apply -f -
```

### Usage
Once deployed, to have your ingress show up in the dashboard provided by
Forecastle:
```shell
kubectl annotate ingress YOUR_INGRESS "forecastle.stakater.com/expose=true" --overwrite
```

## Important notes
The `kubernetes.io/ingress.class` annotation is required by Forecastle to have
the ingress displayed in the dashboard, therefore you need to add such annotation to
all your ingresses even when using a single ingress controller.
