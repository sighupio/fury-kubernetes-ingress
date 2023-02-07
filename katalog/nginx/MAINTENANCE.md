# NGINX ingress controller package maintenance guide

To update NGINX ingress controller, follow the next steps:

Go to the [NGINX ingress controller repository](https://github.com/kubernetes/ingress-nginx/) and check the latest release.

Controller releases are published as `controller-vX.Y.Z` tags.

From the latest release download the zip file and extract it.

Check the folder `charts`, there should be a `ingress-nginx` folder.

Helm template the content using the following command:

```bash
helm template ingress-nginx ./charts/ingress-nginx -n ingress-nginx > templated-from-helm.yaml
```

Create a dummy kustomize project with `templated-from-helm.yaml` as a resource and built it.

```bash
kustomize build dummy-project > templated-from-helm-to-kustomize.yaml
```

Build the current nginx project and compare the output with the previous one.

```bash
kustomize build katalog/nginx > templated-from-katalog.yaml

bcompare templated-from-katalog.yaml templated-from-helm-to-kustomize.yaml
# OR 
diff templated-from-katalog.yaml templated-from-helm-to-kustomize.yaml
```

Check the differences and port them to the `bases/controller` and `bases/configs` folders.

Do the build and compare till there are no important differences.



# CHANGELOG

### ConfigMap Pameters

  - We added `allow-snippet-annotations` and mark it true, from the 1.5.1 release to permit advanced configuration with snippets.
