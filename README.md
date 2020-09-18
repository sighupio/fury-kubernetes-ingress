# Fury Kubernetes Ingress

This repo contains Ingress Controller and TLS certificate management components you need to manage external access to
your services in your cluster.

## Ingress Packages

The following packages are included in Fury Kubernetes Ingress katalog:

- [cert-manager](katalog/cert-manager): cert-manager is a Kubernetes
add-on to automate the management and issuance of TLS certificates
from various issuing sources. Version: **v1.0.1**
- [forecastle](katalog/forecastle): Forecastle gives you access to a control
panel where you can see your running applications and access them
on Kubernetes. Version: **1.0.57**.
- [nginx](katalog/nginx): The NGINX Ingress Controller for Kubernetes
provides delivery services for Kubernetes applications. Version: **0.35.0**
- [dual-nginx](katalog/dual-nginx): It deploys two identical NGINX ingress controllers
but with two different scopes: public/external and private/internal. Version: **0.35.0**
- [nginx-ldap-auth](katalog/nginx-ldap-auth): Use this to provide an ingress authentication over LDAP for
Kubernetes. Version: **1.0.6**


## Compatibility

| Module Version / Kubernetes Version | 1.14.X             | 1.15.X             | 1.16.X             | 1.17.X             | 1.18.X             | 1.19.X             |
|-------------------------------------|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|
| v1.1.0                              |                    |                    |                    |                    |                    |                    |
| v1.2.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| v1.3.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| v1.4.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| v1.5.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| v1.6.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| v1.6.1                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| v1.7.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |
| v1.8.0                              |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |      :warning:     |

- :white_check_mark: Compatible
- :warning: Has issues
- :x: Incompatible

### Warning

- :warning: : module version: `v1.8.0` and Kubernetes Version: `1.19.x`. It works as expected. Marked as warning
because it is not officially supported by [SIGHUP](https://sighup.io).

## LICENSE

For license details please see [LICENSE](LICENSE)
