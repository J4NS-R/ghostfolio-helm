[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/ghostfolio-unofficial)](https://artifacthub.io/packages/search?repo=ghostfolio-unofficial)
[![Latest Tag](https://img.shields.io/github/v/release/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/releases)
[![Project License](https://img.shields.io/github/license/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/blob/master/LICENSE)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/commits/master/)
[![GitHub Commit Activity](https://img.shields.io/github/commit-activity/m/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/commits/master/)
[![GitHub Repository](https://img.shields.io/badge/GitHub-ghostfolio--helm-lightgrey)](https://github.com/J4NS-R/ghostfolio-helm)

# Unofficial Ghostfolio Helm Chart

This project provides a Helm chart for deploying **[Ghostfolio: the Open Source Wealth Management Software](https://github.com/ghostfolio/ghostfolio)** into any Kubernetes cluster. It integrates the official Docker images built by the Ghostfolio team, hosted on [DockerHub](https://hub.docker.com/r/ghostfolio/ghostfolio). It also includes PostgreSQL and [Valkey](https://github.com/valkey-io/valkey-helm) as optional subcharts.

## Installation

### Add the GitHub Helm repository

```bash
helm repo add ghostfolio https://j4ns-r.github.io/ghostfolio-helm/
helm repo update
# list versions
helm search repo --versions ghostfolio
```

### Install the chart

Create a values file configuring the chart:

```yaml
# Optional: pin specific ghostfolio image tag. Default is chart appVersion
# image:
#   tag: 1.2.3

ghostfolio:
  existingSecret: gf-secret # required keys: JWT_SECRET_KEY, ACCESS_TOKEN_SALT
  # Optionally specify arbitrary env vars: https://github.com/ghostfolio/ghostfolio#supported-environment-variables
  # ROOT_URL: "http://ghostfolio.ghostfolio.svc.cluster.local"

valkey:
  auth:
    usersExistingSecret: valkey-secret  # required key: default

postgres:
  auth:
    existingSecret: pg-secret  # required keys: postgres-password, uri
```

Then create the required secrets in-cluster. For example:

```bash
kubectl create secret generic gf-secret \
  --from-literal=JWT_SECRET_KEY=$(openssl rand -hex 24) \
  --from-literal=ACCESS_TOKEN_SALT=$(openssl rand -hex 24)
kubectl create secret generic valkey-secret \
  --from-literal=default=$(openssl rand -hex 24)
pgpassword=$(openssl rand -hex 24)
kubectl create secret generic pg-secret --from-literal=postgres-password="$pgpassword" --from-literal=uri="postgresql://ghostfolio-user:$pgpassword@ghostfolio-postgres:5432/ghostfolio-db"
```

And finally, install:

```bash
helm upgrade --install ghostfolio ghostfolio/ghostfolio -f values.yaml -n <namespace>
```

### Verify the deployment

```bash
kubectl get pods -l app.kubernetes.io/instance=ghostfolio -n <namespace>
# Once all pods are up:
helm test ghostfolio -n <namespace>
```

### Uninstall the chart

```bash
helm uninstall ghostfolio -n <namespace>
```

## Changelog and breaking changes

This repo follows semantic versioning.
See the [changelog on ArtifactHub](https://artifacthub.io/packages/helm/ghostfolio-unofficial/ghostfolio?modal=changelog)

## License

Distributed under the Apache 2.0 License. See `LICENSE` for more information.

## Contributing

PR's welcome. See `CONTRIBUTING.md`

<p align="right"><a href="#ghostfolio-helm-chart">back to top</a></p>
