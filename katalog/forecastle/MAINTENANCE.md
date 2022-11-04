# Forecastle Package Maintenance Guide

To update Forecaste, follow the next steps:

1. Compare the manifests with upstream and port the required modifications.

> Forecastle manifests are taken from upstream from the following URL:
> <https://github.com/stakater/Forecastle/tree/master/deployments/kubernetes/manifests>

2. Update the image tags and sync them to our registry

## Customizations

- Forecastle deployment has been tweaked to include some security features like:
  - changing the user that the image runs as
  - setting the UIDs
  - liveness and readiness probes
- Deleted Helm labels from all resources
- The configuration file `config.yaml` has been personalized with Fury branding
