# Fury Kubernetes Ingress

This repo contains Ingress Controller and TLS certificate management components you need to manage external access to
your services in your cluster.

## Ingress Packages

Following packages are included in Fury Kubernetes Ingress katalog:

- [cert-manager](katalog/cert-manager): cert-manager is a Kubernetes
add-on to automate the management and issuance of TLS certificates
from various issuing sources.. Version: **v0.9.0**
- [forecastle](katalog/forecastle): Forecastle gives you access to a control
panel where you can see your running applications and access them
on Kubernetes. Version: **1.0.34**.
- [nginx](katalog/nginx): The NGINX Ingress Controller for Kubernetes
provides delivery services for Kubernetes applications. Version: **0.26.1**
- [dual-nginx](katalog/dual-nginx): It deploys two identical nginx ingress controllers
but with two different scopes: public/external and private/internal. Version: **0.26.1**
- [nginx-ldap-auth](katalog/nginx-ldap-auth): Use this in order to provide a ingress authentication over LDAP for
Kubernetes. Version: **1.0.6**


## Compatibility

| Module Version / Kubernetes Version | 1.14.X             | 1.15.X             | 1.16.X             |
|-------------------------------------|:------------------:|:------------------:|:------------------:|
| v1.1.0                              |                    |                    |                    |
| v1.2.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.3.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.4.0                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.4.1                              | :white_check_mark: | :white_check_mark: | :white_check_mark: |

- :white_check_mark: Compatible
- :warning: Has issues
- :x: Incompatible
