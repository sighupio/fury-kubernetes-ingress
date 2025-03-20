# Forecastle Package Maintenance Guide

To update Forecastle, follow the next steps:

1. Compare the manifests with upstream and port the required modifications.

> Forecastle manifests are taken from upstream from the following URL:
> <https://github.com/stakater/Forecastle/tree/master/deployments/kubernetes/manifests>

2. Update the image tags and sync them to our registry

## Customizations

- Forecastle deployment has been tweaked to include some security features like:
  - changed the user that the image runs as
  - set the UID
  - liveness and readiness probes
  - added seccompProfile directive to securityContext
- Deleted Helm labels from all resources
- The configuration file `config.yaml` has been personalized with Fury branding
- We did not port the RBAC for traefik ingressoutes objects, we don't use it.
