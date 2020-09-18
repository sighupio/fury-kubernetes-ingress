# NGINX Ingress Controller for GKE

Ingress NGINX is an Ingress Controller for [NGINX](https://nginx.org) webserver and reverse proxy, it manages NGINX in a Kubernetes native manner. This package deploys Ingress Controller for GKE.

## Requirements

- Kubernetes >= `1.10.0`
- Kustomize >= `v1`

## Image repository and tag

* Ingress NGINX GKE image: `quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.19.0`
* Ingress NGINX CKE repo: [https://github.com/kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx)


## Configuration

Fury distribution NGINX GKE is deployed with following configuration:

- Maximum allowed size of the client request body: `10m`
- HTTP status code used in redirects: `301`
- Metrics are scraped by Prometheus every `10s`


## Deployment

You can deploy NGINX GKE by running following command in the root of the project:

`$ kustomize build | kubectl apply -f -`


## Alerts

Followings Prometheus [alerts](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/) are already defined for this package.

### ingress-nginx.rules
| Parameter | Description | Severity | Interval |
|------|-------------|----------|:-----:|
| NginxIngressDown | This alert fires if Promethes target discovery was not able to reach ingress-nginx-metrics in the last 15 minutes. | critical | 15m |
| NginxIngressFailureRate | This alert fires if the failure rate (the rate of 5xx reponses) measured on a time window of 2 minutes was higher than 10% in the last 10 minutes. | critical | 10m |
| NginxIngressFailedReload | This alert fires if the ingress' configuration reload failed in the last 10 minutes. | warning | 10m |
| NginxIngressLatencyTooHigh | This alert fires if the ingress 99th percentile latency was more than 5 seconds in the last 10 minutes. | warning | 10m |
| NginxIngressLatencyTooHigh | This alert fires if the ingress 99th percentile latency was more than 10 seconds in the last 10 minutes. | critical | 10m |
| NginxIngressCertificateExpiration | This alert fires if the certificate for a given host is expiring in less than 7 days. | warning |  |
| NginxIngressCertificateExpiration | This alert fires if the certificate for a given host is expiring in less than 1 days. | critical |  |


## License

For license details please see [LICENSE](https://sighup.io/fury/license)
