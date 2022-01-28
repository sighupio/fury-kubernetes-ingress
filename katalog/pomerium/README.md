# Pomerium

<!-- <KFD-DOCS> -->

Pomerium is an identity-aware proxy that enables secure access to internal applications. Pomerium provides a standardized interface to add access control to applications regardless of whether the application itself has authorization or authentication baked-in

## Pomerium Setup

This document is intended to give a brief overview on how Pomerium can be implemented, for further details, please look at the [official documentation][pomerium-docs].

## Deploy

The base kustomization file present [here](./kustomization.yaml) allows to quickly integrate this service with an existing Dex service, that could, for example, be connected to LDAP.

> See [Dex official documentation][dex-docs] for more details.

In order to do so, you will need to edit your Dex configuration, adding a static client to be used by Pomerium, like in the example below:

```yaml
>>staticClients:
    - id: "pomerium-auth-client"
      secret: "your-super-secret"
      name: "Pomerium"
      redirectURIs:
       - "https://pomerium.example.com/oauth2/callback"
```

Configure the `redirectURIs` section accordingly to the hosts used for the pomerium ingress.

Once dex is configured correctly, you will need to ovverride the configuration example ([policy](./config/policy.example.yaml) and environment variables via a [configmap](./config/config.example.env) and [secret](secrets/pomerium.example.env)) like in the example below:

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

Just copy the examples in the module and override them according to your settings.

**⚠ WARNING: in the policy file, you'll need to set up a policy for each ingress you want to protect with Pomerium authorization service.**

## Ingresses

Once Pomerium and Dex are correctly configured, the last step is to add annotations to the ingresses you've added previously in the policy yaml file:

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
              service:
                name: prometheus-k8s
                port:
                  name: web
  tls:
    - hosts:
        - prometheus.example.com
      secretName: prometheus-tls
```

Now if you'll try to reach the `prometheus.example.com` you'll be forwarded to the dex login page accordingly with the rules set in your policy. Enjoy!

<!-- Links -->
[pomerium-docs]: https://www.pomerium.io/docs/
[dex-docs]: https://dexidp.io/docs/kubernetes/

<!-- </KFD-DOCS> -->
