# External-DNS Package Maintenance Guide

To update External-DNS, follow these steps:

1. Compare the manifests with upstream and port the required modifications.

   External-DNS manifests are taken from upstream from the following URL:
   <https://github.com/kubernetes-sigs/external-dns/tree/master/kustomize>

2. Update the image tags and sync them to our registry.

## Customizations

- The External-DNS deployment has been adjusted to include certain security features such as:
  - Changing the user that the image runs as
  - Setting the UIDs
  - Adding liveness and readiness probes

It's crucial to pay careful attention to changes in RBACs or any variation in the deployment. Additionally, thoroughly review any breaking changes indicated by the provider.
