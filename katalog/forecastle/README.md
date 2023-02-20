# Forecastle

<!-- <KFD-DOCS> -->

[Forecastle][forecastle-page] provides a handy dashboard to show all the applications running on Kubernetes exposed through an Ingress.

## Requirements

- Kubernetes >= `1.20.0`
- Kustomize >= `v3.5.3`

## Image repository and tag

- Forecastle image: `docker.io/stakater/forecastle:v1.0.119`
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

```yaml
apiVersion: forecastle.stakater.com/v1alpha1
kind: ForecastleApp
metadata:
  name: app-name
spec:
  name: My Awesome App
  group: dev
  icon: https://icon-url
  url: http://app-url
  networkRestricted: "false"
  properties:
    Version: 1.0
  instance: "" # Optional
```

##### Automatically discover URL's from Kubernetes Resources

Forecastle supports discovering URL's ForecastleApp CRD from the following resources:

- Ingress

The above type of resource that you want to discover URL from **MUST** exist in the same namespace as `ForecastleApp` CR. Then you can add the following to the CR:

```yaml
apiVersion: forecastle.stakater.com/v1alpha1
kind: ForecastleApp
metadata:
  name: app-name
spec:
  name: My Awesome App
  group: dev
  icon: https://icon-url
  urlFrom: # This is new
    ingressRef:
      name: my-app-ingress
```

## Important notes

The `kubernetes.io/ingress.class` annotation is required by Forecastle to have the ingress displayed in the dashboard, therefore you need to add such annotation to all your ingresses even when using a single ingress controller.

<!-- Links -->
[forecastle-page]: https://github.com/stakater/Forecastle

<!-- </KFD-DOCS> -->
