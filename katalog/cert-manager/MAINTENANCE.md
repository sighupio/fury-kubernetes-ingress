# cert-manager Package Maintenance Guide

You can find the support matrix of cert-manager here:
<https://cert-manager.io/docs/installation/supported-releases/>

Install instructions here:
<https://cert-manager.io/docs/installation/kubectl/>

Upgrade instructions are here:
<https://cert-manager.io/docs/installation/upgrading/>
There are also docs for each minor upgrade, for example:
<https://cert-manager.io/docs/installation/upgrading/upgrading-1.6-1.7>

And here you can find instructions on how to verify that the installation is OK:
<https://cert-manager.io/docs/installation/verify/>

or you can use this tool also:
<https://github.com/alenkacz/cert-manager-verifier>

## Customizations

Upstream cert-manager uses the `kube-system` namespace for the leader election lock. We are deploying everything, including the leader election lock, in the `cert-manager` namespace.

We needed to add a custom snippet to the RBAC in version 1.13.0 of the module that was not included (or was deleted) in upstream.

References:

- <https://github.com/sighupio/fury-kubernetes-ingress/issues/91>
- <https://github.com/cert-manager/cert-manager/issues/5471>
- <https://github.com/cert-manager/cert-manager/issues/4102>

## Update guide

1. Download upstream manifests:

```bash
export CERT_MANAGER_VERSION=1.11.0
curl --location --remote-name https://github.com/cert-manager/cert-manager/releases/download/v${CERT_MANAGER_VERSION}/cert-manager.yaml
```

2. Split the absurdily large YAML into smaller pieces with the [kubernetes-split-yaml](github.com/mogensen/kubernetes-split-yaml) tool:

```bash
# Install the tool if you don't have it in your system
go install github.com/mogensen/kubernetes-split-yaml@v0.4.0
# split the file, the generated files will be found in the `generated` folder
kubernetes-split-yaml cert-manager.yaml
```

3. Compare the downloaded file with our module manifests:

For example for to compare the CA Injector RBAC manifests:

```bash
# Assuming PWD == the folder with the splitted yamls
# You might need to twek the order of the files concatenated.
mkdir cainjector
mv cert-manager-cainjector-* cainjector
cd cainjector
mkdir done

cat cert-manager-cainjector-sa.yaml \
    cert-manager-cainjector-cr.yaml \
    cert-manager-cainjector-crb.yaml \
    cert-manager-cainjector:leaderelection-role.yaml \
    cert-manager-cainjector:leaderelection-rb.yaml \
    > cert-manager-cainjector-rbac.yaml
# move the files to a "done" folder to know that you've checked them.
mv cert-manager-cainjector-sa.yaml \
    cert-manager-cainjector-cr.yaml \
    cert-manager-cainjector-crb.yaml \
    cert-manager-cainjector:leaderelection-role.yaml \
    cert-manager-cainjector:leaderelection-rb.yaml \
    done


diff cert-manager-cainjector-rbac.yaml ../katalog/cert-manager/cainjector/rbac.yaml  # or the tool of your choice.
# do the same for the rest of the files.
```

For the Webhook

```bash
# Assuming PWD == the folder with the splitted yamls
mkdir webhook
mv cert-manager-webhook-* webhook
cd webhook
mkdir done

cat cert-manager-webhook-sa.yaml \
    cert-manager-webhook:subjectaccessreviews-cr.yaml \
    cert-manager-webhook:subjectaccessreviews-crb.yaml \
    cert-manager-webhook:dynamic-serving-role.yaml \
    cert-manager-webhook:dynamic-serving-rb.yaml \
    > rbac.yaml
mv cert-manager-webhook-sa.yaml \
    cert-manager-webhook:subjectaccessreviews-cr.yaml \
    cert-manager-webhook:subjectaccessreviews-crb.yaml \
    cert-manager-webhook:dynamic-serving-role.yaml \
    cert-manager-webhook:dynamic-serving-rb.yaml \
    done

cat cert-manager-webhook-mutatingwebhookconfiguration.yaml \
    cert-manager-webhook-validatingwebhookconfiguration.yaml \
    > webhookconfig.yaml
mv cert-manager-webhook-mutatingwebhookconfiguration.yaml \
    cert-manager-webhook-validatingwebhookconfiguration.yaml \
    done

cat cert-manager-webhook-deployment.yaml \
    cert-manager-webhook-svc.yaml \
    cert-manager-webhook-cm.yaml \
    > deployment.yaml
mv cert-manager-webhook-deployment.yaml \
    cert-manager-webhook-svc.yaml \
    cert-manager-webhook-cm.yaml \
    done

# Diff the files with the ones in katalog/cert-manamger/webhook
```

For the cert-manager-controller:

```bash
# Assuming PWD == the folder with the splitted yamls
mkdir cert-manager-controller
mv cert-manager-controller-* cert-manager-controller
cd cert-manager-controller
mkdir done

cat certificaterequests.cert-manager.io-crd.yaml \
    certificates.cert-manager.io-crd.yaml \
    challenges.acme.cert-manager.io-crd.yaml \
    clusterissuers.cert-manager.io-crd.yaml \
    issuers.cert-manager.io-crd.yaml \
    orders.acme.cert-manager.io-crd.yaml \
    > crds.yaml
mv certificaterequests.cert-manager.io-crd.yaml \
    certificates.cert-manager.io-crd.yaml \
    challenges.acme.cert-manager.io-crd.yaml \
    clusterissuers.cert-manager.io-crd.yaml \
    issuers.cert-manager.io-crd.yaml \
    orders.acme.cert-manager.io-crd.yaml \
    done

cat cert-manager-deployment.yaml \
    cert-manager-svc.yaml \
    > \
    deployment.yaml
mv cert-manager-deployment.yaml \
    cert-manager-svc.yaml \
    done

cat cert-manager-sa.yaml \
    cert-manager-controller-issuers-cr.yaml \
    cert-manager-controller-clusterissuers-cr.yaml \
    cert-manager-controller-certificates-cr.yaml \
    cert-manager-controller-orders-cr.yaml \
    cert-manager-controller-challenges-cr.yaml \
    cert-manager-controller-certificatesigningrequests-cr.yaml \
    cert-manager-controller-ingress-shim-cr.yaml \
    cert-manager-view-cr.yaml \
    cert-manager-edit-cr.yaml \
    cert-manager-controller-approve:cert-manager-io-cr.yaml \
    cert-manager-controller-issuers-crb.yaml \
    cert-manager-controller-clusterissuers-crb.yaml \
    cert-manager-controller-certificates-crb.yaml \
    cert-manager-controller-orders-crb.yaml \
    cert-manager-controller-challenges-crb.yaml \
    cert-manager-controller-certificatesigningrequests-crb.yaml \
    cert-manager-controller-ingress-shim-crb.yaml \
    cert-manager-controller-approve:cert-manager-io-crb.yaml \
    cert-manager:leaderelection-role.yaml \
    cert-manager:leaderelection-rb.yaml \
    > rbac.yaml
mv cert-manager-sa.yaml \
    cert-manager-controller-issuers-cr.yaml \
    cert-manager-controller-clusterissuers-cr.yaml \
    cert-manager-controller-certificates-cr.yaml \
    cert-manager-controller-orders-cr.yaml \
    cert-manager-controller-challenges-cr.yaml \
    cert-manager-controller-certificatesigningrequests-cr.yaml \
    cert-manager-controller-ingress-shim-cr.yaml \
    cert-manager-view-cr.yaml \
    cert-manager-edit-cr.yaml \
    cert-manager-controller-approve:cert-manager-io-cr.yaml \
    cert-manager-controller-issuers-crb.yaml \
    cert-manager-controller-clusterissuers-crb.yaml \
    cert-manager-controller-certificates-crb.yaml \
    cert-manager-controller-orders-crb.yaml \
    cert-manager-controller-challenges-crb.yaml \
    cert-manager-controller-certificatesigningrequests-crb.yaml \
    cert-manager-controller-ingress-shim-crb.yaml \
    cert-manager-controller-approve:cert-manager-io-crb.yaml \
    cert-manager:leaderelection-role.yaml \
    cert-manager:leaderelection-rb.yaml \
    done
```

4. Port the needed changes to the module's manifests.

5. Remember to sync the new images to SIGHUP's registry.

## Dashboards

The included Grafana dashbaord seems to be taken from here: <https://grafana.com/grafana/dashboards/11001-cert-manager/>. It has not been updated in a while.
