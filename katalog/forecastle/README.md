# Forecastle

<!-- <KFD-DOCS> -->

[Forecastle][forecastle-page] provides a handy dashboard to show all the applications running on Kubernetes exposed through an Ingress.

## Requirements

- Kubernetes >= `1.20.0`
- Kustomize >= `v3.5.3`

## Image repository and tag

- Forecastle image: `docker.io/stakater/forecastle:v1.0.136`
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
#### ForecastleApp CRD

You can now create custom resources to add apps to forecastle dynamically. This decouples the application configuration from Ingresses as well as forecastle config. You can create the custom resource `ForecastleApp` like the following:

#### example CR

```yaml
apiVersion: forecastle.stakater.com/v1alpha1
kind: ForecastleApp
metadata:
  name: sighup-example-app
  namespace: ingress-nginx
  labels:
    app: forecastle
spec:
  name: sighup
  group: dev
  icon: https://raw.githubusercontent.com/sighupio/fury-distribution/main/docs/assets/fury-epta-white.png
  url: https://sighup.io/
  networkRestricted: false
  properties:
    Version: "1"
```

##### Automatically discover URL's from Kubernetes Resources

Forecastle supports discovering URL's ForecastleApp CRD from the following resources:
- Ingress

## Important notes

The `kubernetes.io/ingress.class` annotation is required by Forecastle to have the ingress displayed in the dashboard, therefore you need to add such annotation to all your ingresses even when using a single ingress controller.

<!-- Links -->
[forecastle-page]: https://github.com/stakater/Forecastle

<!-- </KFD-DOCS> -->
