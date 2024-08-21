# NGINX ingress controller package maintenance guide

> ⚠️ **WARNING**: this guide is not complete.
>
> You will find differences between the files from upstream to our manifests that are not explained in the instructions.
> Please update this guide if you know how to align them.
> See the [Expected Differences](#expected-differences) section for more details.

To update NGINX ingress controller, follow the next steps:

## Getting upstream files - option 1

1. Go to the [NGINX ingress controller repository](https://github.com/kubernetes/ingress-nginx/) and check the latest release.

> Controller releases are published as `controller-vX.Y.Z` tags.

2. From the latest release download the zip file and extract it.

3. Check the folder `charts`, there should be a `ingress-nginx` folder.

Helm template the content using the following command:

```bash
helm template ingress-nginx ./charts/ingress-nginx \
--namespace ingress-nginx \
--set fullNameOverride=ingress-nginx \
--set controller.kind=DaemonSet \
--set controller.image.registry=registry.sighup.io \
--set controller.image.image=fury/ingress-nginx/controller \
--set controller.image.pullPolicy=Always \
--set controller.image.allowPrivilegeEscalation=true \
--set controller.containerPort.http=8080 \
--set controller.containerPort.https=8443 \
--set controller.allowSnippetAnnotations=true \
--set controller.service.type=NodePort \
--set controller.service.nodePorts.http=31080 \
--set controller.service.nodePorts.https=31443 \
--set controller.service.externalTrafficPolicy=Local \
--set controller.admissionWebhooks.port=9443 \
--set controller.admissionWebhooks.service.servicePort=9443 \
--set controller.admissionWebhooks.patch.enabled=false \
--set controller.admissionWebhooks.certManager.enabled=true \
--set controller.admissionWebhooks.certManager.enabled=true \
--set controller.metrics.enabled=true \
--set controller.metrics.serviceMonitor.enabled=true \
--set controller.metrics.serviceMonitor.additionalLabels.k8s-app=ingress-nginx \
--set controller.metrics.serviceMonitor.scrapeInterval=10s \
--set controller.metrics.serviceMonitor.jobLabel=k8s-app \
--set controller.metrics.prometheusRule.enabled=true \
--set controller.metrics.prometheusRule.additionalLabels.prometheus=k8s \
--set controller.customTemplate.configMapName=nginx-configuration \
--set controller.config.enable-access-log-for-default-backend=true \
--set controller.config.http-redirect-code=301 \
--set controller.config.proxy-body-size=10m \
--set controller.updateStrategy.type=RollingUpdate \
--set controller.updateStrategy.rollingUpdate.maxSurge=1 \
--set controller.updateStrategy.rollingUpdate.maxUnavailable=0 \
--set controller.podSecurityContext.fsGroup=101 \
--set controller.ingressClassResource.default=true \
> templated-from-helm.yaml
```

## Getting upstream files - option 2

Search for the version of the chart that installs your desired version of the controller (for example, chart v4.11.2 installs the controller v1.11.2) and run the following command:

> ❗️ change the `--version` flag with the right verison.
>
> You can check the version of the controller in the Chart.yaml file inside the chart.

```bash
helm template ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --version 4.11.2 \
  --namespace ingress-nginx \
  --set fullNameOverride=ingress-nginx \
  --set controller.kind=DaemonSet \
  --set controller.image.registry=registry.sighup.io \
  --set controller.image.image=fury/ingress-nginx/controller \
  --set controller.image.pullPolicy=Always \
  --set controller.image.allowPrivilegeEscalation=true \
  --set controller.containerPort.http=8080 \
  --set controller.containerPort.https=8443 \
  --set controller.allowSnippetAnnotations=true \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=31080 \
  --set controller.service.nodePorts.https=31443 \
  --set controller.service.externalTrafficPolicy=Local \
  --set controller.admissionWebhooks.port=9443 \
  --set controller.admissionWebhooks.service.servicePort=9443 \
  --set controller.admissionWebhooks.patch.enabled=false \
  --set controller.admissionWebhooks.certManager.enabled=true \
  --set controller.admissionWebhooks.certManager.enabled=true \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.enabled=true \
  --set controller.metrics.serviceMonitor.additionalLabels.k8s-app=ingress-nginx \
  --set controller.metrics.serviceMonitor.scrapeInterval=10s \
  --set controller.metrics.serviceMonitor.jobLabel=k8s-app \
  --set controller.metrics.prometheusRule.enabled=true \
  --set controller.metrics.prometheusRule.additionalLabels.prometheus=k8s \
  --set controller.customTemplate.configMapName=nginx-configuration \
  --set controller.config.enable-access-log-for-default-backend=true \
  --set controller.config.http-redirect-code=301 \
  --set controller.config.proxy-body-size=10m \
  --set controller.updateStrategy.type=RollingUpdate \
  --set controller.updateStrategy.rollingUpdate.maxSurge=1 \
  --set controller.updateStrategy.rollingUpdate.maxUnavailable=0 \
  --set controller.podSecurityContext.fsGroup=101 \
  --set controller.ingressClassResource.default=true \
  > templated-from-helm.yaml
```

## Comparing the diff

Create a dummy kustomize project with `templated-from-helm.yaml` as a resource and built it.

```bash
kustomize build dummy-project > templated-from-helm-to-kustomize.yaml
```

Build the current nginx project and compare the output with the previous one.

> 💡 TIP
> Comment out the grafana dashboard resource from the katalog/ngnix/kustomization.yaml file.
> It adds 5000 lines from the JSON that are not needed in the diff and may break your editor.

```bash
kustomize build katalog/nginx > templated-from-katalog.yaml

bcompare templated-from-katalog.yaml templated-from-helm-to-kustomize.yaml
# OR
diff templated-from-katalog.yaml templated-from-helm-to-kustomize.yaml
```

Check the differences and port them to the `bases/controller` and `bases/configs` folders.

Do the build and compare till there are no important differences.

### Expected differences

The following differences between our manifests and the upstream ones generated by the helm template command are excpected to be found:

- Helm labels have been removed. A `app: ingress-nginx` label is used instead.
- The specs for the Prometheus Rules generated by helm template will be empty for simplicity in the command.
- [ ] FIXME: Some resources names won't match with the ones generated by the helm template command.
- [ ] FIXME: Some flags for the controller command have been added.
- [ ] FIXME: SecurityContext for the controller at container and Pod level don't match with upstream.
- [ ] FIXME: certmanager Certificates objects for the AdmissionWebhook don't match between upstream and ours.

Some of these differences are known issues and we should update the values that we use in the helm template command to align them, or update our manifests to match the upstream one..

## CHANGELOG

### ConfigMap Parameters

We added `allow-snippet-annotations` and mark it true, from the 1.5.1 release to permit advanced configuration with snippets.
