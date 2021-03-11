# Pomerium Setup

This document is intended to give a brief overview on how Pomerium can be implemented, for further details, please look at the official doc : https://www.pomerium.io/docs/

## Setup

the base kustomization component present [here](./kustomization.yaml) allows to quickly integrate this service with an existing Dex service that very likely is connected to an LDAP.

For this reason you will need to edit your Dex configuration in order to add a static client for Pomerium service like in the example above:

```yaml
>>staticClients:
    - id: "pomerium-auth-client"
      secret: "your-super-secret"
      name: "Pomerium"
      redirectURIs:
       - "https://pomerium.example.com/oauth2/callback"
```

setting the redirectURIs, accordingly with the host you used for the pomerium ingress.

Once do that, you will need to use ovverride the configuration example ([policy](./config/policy.example.yaml) and environment variables as [configmap](./config/config.example.env) and [secret](secrets/pomerium.example.env)) like in the example above:

```yaml
configMapGenerator:
    - name: pomerium-policy
      behavior: replace
      files:
          - policy.yml=config/pomerium-policy.yml
    - name: pomerium
      behavior: replace
      envs:
          - config/pomerium-config.env

secretGenerator:
    - name: pomerium-env
      behavior: replace
      envs:
          - secrets/pomerium.env
```

just copy the examples in the module and override them accordingly with your settings.

**⚠ WARNING: in the policy file, you'll need to setup many policy as many ingress you want to protect under the pomerium authorization service.**

## Ingresses

Once do that, Pomerium and Dex and correctly configured.
The only missing step is to add annotations to the ingresses you've added previously in the policy yaml file:

```yaml
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
    annotations:
        forecastle.stakater.com/expose: "true"
        forecastle.stakater.com/appName: "Prometheus"
        forecastle.stakater.com/icon: "https://github.com/stakater/ForecastleIcons/raw/master/prometheus.png"
        kubernetes.io/ingress.class: "internal"
        kubernetes.io/tls-acme: "true"
        # authentication annotations
        nginx.ingress.kubernetes.io/auth-url: "https://pomerium.example.com/verify?uri=$scheme://$host$request_uri"
        nginx.ingress.kubernetes.io/auth-signin: "https://pomerium.example.com/?uri=$scheme://$host$request_uri"
    name: prometheus
    namespace: monitoring
spec:
    rules:
        - host: prometheus.example.com
          http:
              paths:
                  - path: /
                    backend:
                        serviceName: prometheus-k8s
                        servicePort: web
    tls:
        - hosts:
              - prometheus.example.com
          secretName: prometheus-tls
```

Now if you'll try to reach the `prometheus.example.com` you'll be forwarded to the dex login page accordingly with the rules set in your policy. Enjoy!
