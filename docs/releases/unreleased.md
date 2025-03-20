# Kubernetes Fury Ingress Core Module Release TBD

Welcome to the latest release of `Ingress` module of [`Kubernetes Fury Distribution`](https://github.com/sighupio/fury-distribution) maintained by team SIGHUP.

This release updates several packages to the latest versions available for new features, bug fixes and improved security, it also introduces compatibility with Kubernetes 1.32.

## Component versions 🚢

| Component          | Supported Version                                                                        | Previous Version |
| ------------------ | ---------------------------------------------------------------------------------------- | :--------------: |
| `aws-cert-manager` | N.A.                                                                                     |   `No update`    |
| `aws-external-dns` | N.A.                                                                                     |   `No update`    |
| `cert-manager`     | [`v1.17.1`](https://cert-manager.io/docs/releases/release-notes/release-notes-1.17/)     |     `1.16.1`     |
| `external-dns`     | [`v0.16.1`](https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.16.1)        |     `0.15.0`     |
| `forecastle`       | [`v1.0.156`](https://github.com/stakater/Forecastle/releases/tag/v1.0.156)               |    `1.0.156`     |
| `nginx`            | [`v1.12.0`](https://github.com/kubernetes/ingress-nginx/releases/tag/controller-v1.12.0) |     `1.11.3`     |

> Please refer the individual release notes to get a more detailed information on each release.

## Breaking changes 💔

## Ingress NGINX Controller

Upstream Ingress NGINX Controller has introduced some breaking changes in version 1.12.0 included in this version of the ingress module. We recommend reading [upstream's changelog](https://github.com/kubernetes/ingress-nginx/blob/main/changelog/controller-1.12.0.md). Here's a list of changes that could possibly impact you as a user of the module:

- Remove `global-rate-limit` feature. This removes the following configuration options:

  - `global-rate-limit-memcached-host`
  - `global-rate-limit-memcached-port`
  - `global-rate-limit-memcached-connect-timeout`
  - `global-rate-limit-memcached-max-idle-timeout`
  - `global-rate-limit-memcached-pool-size`
  - `global-rate-limit-status-code`

  It also removes the following annotations:

  - `global-rate-limit`
  - `global-rate-limit-window`
  - `global-rate-limit-key`
  - `global-rate-limit-ignored-cidrs`

- Remove 3rd party lua plugin support. This removes the following configuration options:

  - `plugins`

  It also removes support for user provided Lua plugins in the `/etc/nginx/lua/plugins` directory.

## external-dns

A breaking change has been introduced in v0.16.0 for the Cloudflare provider, please see [this link](https://github.com/kubernetes-sigs/external-dns/issues/5166) for more details.

## Upgrade Guide 🦮

> ⚠️ **WARNING**
>
> There are some (possibly) breaking changes, read the Breaking changes section above before continuing.
<!-- spacer -->

> ℹ️ **INFO**
>
> This update guide is for users of the module and not of the Distribution or users still on furyctl legacy.
> If you are a KFD user, the update is performed automatically by furyctl.

### Process

To upgrade this core module from `v3.0.1` to `vTBD`, you need to download this new version and apply the instructions below.

```bash
kustomize build <your-project-path> | kubectl apply -f - --server-side
```

For the Terraform modules, run `terraform init -upgrade`, then apply the new version.
