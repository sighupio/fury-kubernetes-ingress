# NGINX ingress controller package maintenance guide

To update NGINX ingress controller, follow the next steps (or use the [upgrade.sh](./upgrade.sh) script to automate it):

## Local build

Before upgrading, build the current release using:

```bash
kustomize build . > current-release.yaml
```

> 💡 TIP
> Comment out the grafana dashboard resource from the katalog/nginx/kustomization.yaml file.
> It adds 5000 lines from the JSON that are not needed in the diff and may break your editor.


## Upgrade files

1. Go to the [NGINX ingress controller repository](https://github.com/kubernetes/ingress-nginx/) and check the latest release.

> Controller releases are published as `controller-vX.Y.Z` tags.

2. Helm template the content using the following command:

```bash
helm template ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace --version $VERSION --values MAINTENANCE.values.yml | yq --split-exp '.kind + "-" + .metadata.name'
```

3. Sometimes, you might get an empty file called ".yml" from the template, you can safely delete it.

4. Move the files to the correct folders:

```bash
mv ClusterRole-ingress-nginx.yml bases/configs
mv ClusterRoleBinding-ingress-nginx.yml bases/configs
mv Role-ingress-nginx.yml bases/configs
mv RoleBinding-ingress-nginx.yml bases/configs
mv ServiceAccount-ingress-nginx.yml bases/configs
mv ServiceMonitor-ingress-nginx.yml bases/configs
mv Service-ingress-nginx-metrics.yml bases/configs
mv PrometheusRule-ingress-nginx.yml bases/configs
mv Issuer-ingress-nginx-root-issuer.yml bases/configs
mv Issuer-ingress-nginx-self-signed-issuer.yml bases/configs
mv Certificate-ingress-nginx-root-cert.yml bases/configs

mv DaemonSet-ingress-nginx.yml bases/controller
mv ConfigMap-ingress-nginx.yml bases/controller
mv Service-ingress-nginx-admission.yml bases/controller
mv Service-ingress-nginx.yml bases/controller
mv IngressClass-nginx.yml bases/controller
mv Certificate-ingress-nginx-admission.yml bases/controller
mv ValidatingWebhookConfiguration-ingress-nginx-admission.yml bases/controller
```

5. Check that all files are referenced by [./bases/configs/kustomization.yaml](./bases/configs/kustomization.yaml) and [./bases/controller/kustomization.yaml](./bases/controller/kustomization.yaml).

## Compare the Diff

1. Build the new release, like you did before:

```bash
kustomize build . > new-release.yaml
```

> 💡 TIP
> Comment out the grafana dashboard resource from the katalog/nginx/kustomization.yaml file.
> It adds 5000 lines from the JSON that are not needed in the diff and may break your editor.

2. Compare the two releases

```bash
bcompare current-release.yaml new-release.yaml
# OR
diff current-release.yaml new-release.yaml
```

3. If possible, port the relevant differences to [MAINTENANCE.values.yml](./MAINTENANCE.values.yml)

4. If not possible, port them directly to `bases` folders using patches, and document them below.

### Custom patches

- The main Service has been renamed from `ingress-nginx-controller` to `ingress-nginx` to avoid breaking compatibility with the old releases. Reference [here](./bases/controller/kustomization.yaml#24) and [here](./MAINTENANCE.values.yml#17).

## Add license to all files

```bash
go install github.com/google/addlicense@v1.1.1
addlicense -c "SIGHUP s.r.l" -y "2017-present" -v -l bsd .
```

## Updata Grafana Dashboards

check the grafana dashboard in this path: `deploy/grafana/dashboards/nginx.json` of the upstream repository
compare the upstream with the current one, and update it if is needed.
