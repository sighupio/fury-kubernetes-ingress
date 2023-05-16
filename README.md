<!-- markdownlint-disable MD033 -->
<h1>
    <img src="https://github.com/sighupio/fury-distribution/blob/main/docs/assets/fury-epta-white.png?raw=true" align="left" width="90" style="margin-right: 15px"/>
    Kubernetes Fury Ingress
</h1>
<!-- markdownlint-enable MD033 -->

![Release](https://img.shields.io/badge/Latest%20Release-v1.15.0-blue)
![License](https://img.shields.io/github/license/sighupio/fury-kubernetes-ingress?label=License)
![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack&label=Slack)

<!-- <KFD-DOCS> -->
**Kubernetes Fury Ingress** provides Ingress Controllers to expose services and TLS certificate management solutions for the [Kubernetes Fury Distribution (KFD)][kfd-repo].

If you are new to KFD please refer to the [official documentation][kfd-docs] on how to get started with KFD.

## Overview

**Kubernetes Fury Ingress** uses CNCF recommended, Cloud Native projects, such as [Ingress NGINX][ingress-nginx-docs] an ingress controller using the well-known NGINX server as a URL path-based routing reverse proxy and load balancer, and [cert-manager](https://github.com/jetstack/cert-manager) to automate the issuing and renewal of TLS certificates from various issuing sources.

The module also includes additional tools like [Forecastle][forecastle-repo], a web-based global directory of all the services offered by your cluster.

### Architecture

The reference architecture used to deploy the Fury Kubernetes Ingress Module is shown in the following figure:

![Ingress Architecture](/docs/images/fury-ingress.png)

- The traffic from end users arrives first at a Load Balancer that distributes the traffic between the available Ingress Controllers (usually, one for each availability zone).
- Once the traffic reaches the Ingress Controller, the Ingress proxies the traffic to the Kubernetes service based on the URL path of the request.
- The `service` is a Kubernetes abstraction that makes the traffic arrive at the pods where the actual application is running, usually using `iptables` rules.

> For more information, please refer to Kubernetes Ingress [offiicial documentation][kubernetes-ingress]

## Packages

Kubernetes Fury Ingress provides the following packages:

| Package                                       | Version    | Description                                                                                                                   |
| --------------------------------------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [nginx](katalog/nginx)                        | `v1.7.1`   | The NGINX Ingress Controller for Kubernetes provides delivery services for Kubernetes applications.                           |
| [dual-nginx](katalog/dual-nginx)              | `v1.5.1`   | It deploys two identical NGINX ingress controllers but with two different scopes: public/external and private/internal.       |
| [cert-manager](katalog/cert-manager)          | `v1.11.0`  | cert-manager is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources. |
| [external-dns](katalog/external-dns)          | `v0.13.2`  | external-dns allows you to manage DNS records natively from Kubernetes.                                                       |
| [forecastle](katalog/forecastle)              | `v1.0.119` | Forecastle gives you access to a control panel where you can see your ingresses and access them on Kubernetes.                |
| [aws-cert-manager](modules/aws-cert-manager/) | -          | Terraform modules for managing IAM permissions on AWS for cert-manager                                                        |
| [aws-external-dns](modules/aws-external-dns/) | -          | Terraform modules for managing IAM permissions on AWS for external-dns                                                        |

## Compatibility

| Kubernetes Version |   Compatibility    | Notes           |
| ------------------ | :----------------: | --------------- |
| `1.24.x`           | :white_check_mark: | No known issues |
| `1.25.x`           | :white_check_mark: | No known issues |
| `1.26.x`           | :white_check_mark: | No known issues |

Check the [compatibility matrix][compatibility-matrix] for additional information on previous releases of the module.

## Usage

### Prerequisites

| Tool                        | Version   | Description                                                                                                                                                    |
| --------------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [furyctl][furyctl-repo]     | `>=0.6.0` | The recommended tool to download and manage KFD modules and their packages. To learn more about `furyctl` read the [official documentation][furyctl-repo].     |
| [kustomize][kustomize-repo] | `>=3.5.3` | Packages are customized using `kustomize`. To learn how to create your customization layer with `kustomize`, please refer to the [repository][kustomize-repo]. |

### Single vs Dual Controller

As the first step, you should choose what type of ingress controller you want to use in your cluster. Kubernetes Fury Ingress provides two types, Single and Dual Ingress Controller.

The Single Controller Package deploys a single class NGINX Ingress Controller that serves all the internal (private) and external (public) traffic.

The Dual Controller Package creates two NGINX Ingress Controller classes, the `internal-ingress` and the `external-ingress` classes:

- The `internal-ingress` class is in charge of serving traffic inside the cluster's network, like users accessing via VPN to internal services, for example, application's admin panels or other resources that you don't want to expose to the Internet.

- The `external-ingress` class serves traffic for the applications exposed to the outside of the cluster (e.g., the frontend application to end-users).

### Default Configuration

For both Single and Dual NGINX the Kubernetes Fury Ingress module has the following default configuration:

- Maximum allowed size of the client request body: `10m`
- HTTP status code used in redirects: `301`
- Metrics are scraped by Prometheus every `10s`
- Validating Admission webhook that validates an ingress definition does not break NGINX configuration.

Additionally, the following Prometheus [alerts][prometheus-alerts-page] are set up by default:

| Parameter                           | Description                                                                                                                                         | Severity | Interval |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | :------: |
| `NginxIngressDown`                  | This alert fires if Prometheus target discovery was not able to reach ingress-nginx-metrics in the last 15 minutes.                                 | critical |   15m    |
| `NginxIngressFailureRate`           | This alert fires if the failure rate (the rate of 5xx responses) measured on a time window of 2 minutes was higher than 10% in the last 10 minutes. | critical |   10m    |
| `NginxIngressFailedReload`          | This alert fires if the ingress' configuration reload failed in the last 10 minutes.                                                                | warning  |   10m    |
| `NginxIngressLatencyTooHigh`        | This alert fires if the ingress 99th percentile latency was more than 5 seconds in the last 10 minutes.                                             | warning  |   10m    |
| `NginxIngressLatencyTooHigh`        | This alert fires if the ingress 99th percentile latency was more than 10 seconds in the last 10 minutes.                                            | critical |   10m    |
| `NginxIngressCertificateExpiration` | This alert fires if the certificate for a given host is expiring in less than 7 days.                                                               | warning  |          |
| `NginxIngressCertificateExpiration` | This alert fires if the certificate for a given host is expiring in less than 1 day.                                                                | critical |          |

### Deployment

#### Certificates automation with cert-manager

Kubernetes Fury Ingress cert-manager package is the defacto tool to manage certificates in Kubernetes. It manages the issuing and automatic renewal of certificates for the domains served by the Ingress Controller.

The package's default configuration includes:

- Let's Encrypt as the default certificates issuer, both staging and production.
- `ClusterIssuer` as the default issuer kind

To deploy the `cert-manager` package:

1. Add the package to your bases inside the `Furyfile.yml`:

```yaml
bases:
  - name: ingress/dual-nginx
    version: "v1.15.0"
  - name: ingress/cert-manager
    version: "v1.15.0"
```

2. Execute `furyctl vendor -H` to download the packages

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

#### NGINX Ingress Controller

> ⚠️ You'll need to have deployed [`cert-manager`](../cert-manager/) first, the validating webhook needs to have TLS communication with the API server.

1. Once you selected the type of ingress you want to deploy (`nginx` or `dual-nginx`) the next step is to specify this in a `Furyfile.yml`:

Single Ingress:

```yaml
bases:
  - name: ingress/nginx
    version: "v1.15.0"
```

Dual Ingress:

> `dual-nginx` depends on the `nginx` package, so we need to download both of them.

```yaml
bases:
  - name: ingress/nginx
    version: "v1.15.0"
  - name: ingress/dual-nginx
    version: "v1.15.0"
```

> See `furyctl` [documentation][furyctl-repo] for additional details about `Furyfile.yml` format.

2. Execute `furyctl vendor -H` to download the packages

3. Inspect the download packages under `./vendor/katalog/ingress/`.

4. Define a `kustomization.yaml` that includes the `./vendor/katalog/ingress` directory as resource.

```yaml
resources:
- ./vendor/katalog/ingress
```

5. Apply the necessary patches. You can find a list of common customization [here](#common-customizations).

6. To deploy the packages to your cluster, execute:

```bash
kustomize build . | kubectl apply -f -
```

Your are now ready to expose your applications using Kubernetes `Ingress` objects.

### Common customizations

`nginx` package is deployed by default as a `DaemonSet`, meaning that it will deploy 1 ingress-controller pod on every worker node.

This is probably NOT what you want, standard Fury clusters have at least 1 `infra` node (nodes that are dedicated to run Fury infrastructural components, like Prometheus, elasticsearch, and the ingress controllers).

If your cluster has `infra` nodes you should patch the daemonset adding the `NodeSelector` for the `infra` nodes to the Ingress `DaemonSet`. You can do this using the following kustomize patch:

```yaml
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-ingress-controller-external
spec:
  template:
    spec:
      nodeSelector:
        node-kind.sighup.io/infra: ""
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-ingress-controller-internal
spec:
  template:
    spec:
      nodeSelector:
        node-kind.sighup.io/infra: ""
```

If you don't have infra nodes and you don't want to run ingress-controllers on all your worker nodes, you should probably label some nodes and adjust the previous `NodeSelector` accordingly.

#### Applications directory with Forecastle

Forecastle list all the annotated ingress (applications) that exists in your cluster with an icon grouped by namesapce, in a nice web UI. It lets you search, personalize the header for the landing page (title and colors), it lets you list custom ingress and add more details to each entry.

Use Forecastle as your cluster entry point to discover the running applications easily.

To deploy the `forecastle` package:

1. Add the package to your bases inside the `Furyfile.yml`:

```yaml
bases:
  - name: ingress/dual-nginx
    version: "v1.15.0"
  - name: ingress/cert-manager
    version: "v1.15.0"
  - name: ingress/forecastle
    version: "v1.15.0"
```

2. Execute `furyctl vendor -H` to download the packages

3. Inspect the download packages under `./vendor/katalog/ingress/forecastle`.

4. Define a `kustomization.yaml` that includes the `./vendor/katalog/ingress/forecastle` directory as resource.

```yaml
resources:
- ./vendor/katalog/ingress/forecastle
```

5. Finally, execute the following command to deploy the package:

```shell
kustomize build . | kubectl apply -f -
```

##### Basic usage

Forecastle looks for specific annotations on ingresses objects.

Add the following annotations to your ingresses to be discovered by Forecastle:

| Annotation                                   | Description                                                                                                                                               | Required |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| `forecastle.stakater.com/expose`             | Add this with value `true` to the ingress of the app you want to show in Forecastle                                                                       | `true`   |
| `forecastle.stakater.com/icon`               | Icon/Image URL of the application; An icons/logos/images collection repo [Icons][forecastle-icons]                                                        | `false`  |
| `forecastle.stakater.com/appName`            | A custom name for your application. Default is the name of the ingress                                                                                    | `false`  |
| `forecastle.stakater.com/group`              | A custom group name. Use if you want the application to show in a different group than the namespace it belongs to                                        | `false`  |
| `forecastle.stakater.com/instance`           | A comma-separated list of name/s of the forecastle instance/s where you want this application to appear. Use when you have multiple forecastle dashboards | `false`  |
| `forecastle.stakater.com/url`                | A URL for the forecastle app (This will override the ingress URL). It *must* begin with a scheme i.e. `http://` or `https://`                             | `false`  |
| `forecastle.stakater.com/properties`         | A comma separate list of key-value pairs for the properties. This will appear as an expandable list for the app                                           | `false`  |
| `forecastle.stakater.com/network-restricted` | Specify whether the application is network restricted or not (true or false)                                                                              | `false`  |

> See Forecastle [official repository][forecastle-repository] for more details.

<!-- Links -->
[furyctl-repo]: https://github.com/sighupio/furyctl
[sighup-page]: https://sighup.io
[kfd-repo]: https://github.com/sighupio/fury-distribution
[kustomize-repo]: https://github.com/kubernetes-sigs/kustomize
[kfd-docs]: https://docs.kubernetesfury.com/docs/distribution/
[compatibility-matrix]: https://github.com/sighupio/fury-kubernetes-ingress/blob/main/docs/COMPATIBILITY_MATRIX.md
[kubernetes-ingress]: https://kubernetes.io/docs/concepts/services-networking/ingress/
[forecastle-repo]: https://github.com/stakater/Forecastle
[forecastle-icons]: https://github.com/stakater/ForecastleIcons
[forecastle-repository]: https://github.com/stakater/Forecastle/blob/v1.0.61/README.md
[ingress-nginx-docs]: https://github.com/kubernetes/ingress-nginx
[prometheus-alerts-page]: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
<!-- </KFD-DOCS> -->

<!-- <FOOTER> -->
## Contributing

Before contributing, please read first the [Contributing Guidelines](docs/CONTRIBUTING.md).

### Reporting Issues

In case you experience any problems with the module, please [open a new issue](https://github.com/sighupio/fury-kubernetes-ingress/issues/new/choose).

## License

This module is open-source and it's released under the following [LICENSE](LICENSE)
<!-- </FOOTER> -->
