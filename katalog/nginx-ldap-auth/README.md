# NGINX LDAP Auth

[NGINX LDAP Auth](https://github.com/tiagoapimenta/nginx-ldap-auth/blob/v1.0.6/README.md) provides ingress
authentication over LDAP for Kubernetes.


## Requirements

- Kubernetes >= `1.14.0`
- Kustomize >= `v3`


## Image repository and tag

* NGINX LDAP Auth image: `docker.io/tpimenta/nginx-ldap-auth:1.0.6`
* NGINX LDAP Auth repo:
[https://github.com/tiagoapimenta/nginx-ldap-auth](https://github.com/tiagoapimenta/nginx-ldap-auth/tree/v1.0.6)


## Configuration

NGINX LDAP Auth is deployed with following configuration:

- POD runs unprivileged
- POD with limited hardened rbac configuration
- POD with limited resources


### LDAP Configuration

The NGINX LDAP Auth needs a kubernetes secret named `nginx-ldap-auth` with a `config.yaml` key. An example is available
under the [`config`](config) directory.

```bash
$ kustomize build katalog/nginx-ldap-auth/config/
apiVersion: v1
data:
  config.yaml: d2ViOiAwLjAuMC4wOjU1NTUKcGF0aDogLwpzZXJ2ZXJzOgogIC0gbGRhcDovL2xkYXAtc2VydmVyCmF1dGg6CiAgYmluZEROOiBjbj1hZG1pbixkYz1zaWdodXAsZGM9aW8KICBiaW5kUFc6IEhhdEZyaWRheQp1c2VyOgogIGJhc2VETjogb3U9Z3JvdXAtYSxvdT1zeXN0ZW0sZGM9c2lnaHVwLGRjPWlvCiAgZmlsdGVyOiAiKGNuPXswfSkiCg==
kind: Secret
metadata:
  name: nginx-ldap-auth
  namespace: ingress-nginx
type: Opaque
```

Note that [`config.yaml`](config/sample.config.yaml) property is a file with the NGINX LDAP Auth:

```yaml
web: 0.0.0.0:5555
path: /
servers:
  - ldap://ldap-server
auth:
  bindDN: cn=admin,dc=sighup,dc=io
  bindPW: HatFriday
user:
  baseDN: ou=group-a,ou=system,dc=sighup,dc=io
  filter: "(cn={0})"
```

To know all available configuration options
[go to the upstream project at github](https://github.com/tiagoapimenta/nginx-ldap-auth/tree/v1.0.6).

More configuration examples under [tests/nginx-ldap-auth](../../katalog/tests/nginx-ldap-auth) including
[one filtering users by LDAP groups](../../katalog/tests/nginx-ldap-auth/nginx-ldap-auth-config-groups.yaml):

```yaml
web: 0.0.0.0:5555
path: /
servers:
  - ldap://ldap-server.demo-ldap.svc.cluster.local
auth:
  bindDN: cn=admin,dc=sighup,dc=io
  bindPW: HatFriday
user:
  baseDN: ou=people,dc=sighup,dc=io
  filter: "(cn={0})"
  requiredGroups:
  - amministrazione
  - engineering
group:
  baseDN: ou=groups,dc=sighup,dc=io
  groupAttr: cn
  filter: "(member={0})"
```


## Deployment

You can deploy NGINX LDAP Auth by running following command in the root of the project:

```bash
$ kustomize build katalog/nginx-ldap-auth/config/  | kubectl apply -f -
# omitted output
$ kustomize build katalog/nginx-ldap-auth  | kubectl apply -f -
# omitted output
```


### Usage

Once deployed, any ingress definition can be configured to be protected by HTTP basic access authentication against LDAP:

```bash
kubectl annotate ingress YOUR_INGRESS "nginx.ingress.kubernetes.io/auth-url=http://nginx-ldap-auth.ingress-nginx.svc.cluster.local" --overwrite
```

More information related to NGINX ingress defintion authentication can be found at the NGINX ingress
[official documentation site](https://kubernetes.github.io/ingress-nginx/examples/auth/external-auth/)


## Important note

Be aware this authentication method is transmitted in every request by your browser in plain text, so you should
be using https.


## License

For license details please see [LICENSE](../../LICENSE)
