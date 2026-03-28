[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/ghostfolio-unofficial)](https://artifacthub.io/packages/search?repo=ghostfolio-unofficial)
[![Latest Tag](https://img.shields.io/github/v/release/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/releases)
[![Project License](https://img.shields.io/github/license/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/blob/master/LICENSE)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/commits/master/)
[![GitHub Commit Activity](https://img.shields.io/github/commit-activity/m/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/commits/master/)
[![GitHub Repository](https://img.shields.io/badge/GitHub-ghostfolio--helm-lightgrey)](https://github.com/J4NS-R/ghostfolio-helm)

![Ghostfolio Helm banner](docs/ghostfolio-helm-banner.png)

# Unofficial Ghostfolio Helm Chart

This project provides a _Helm_ chart for deploying **[Ghostfolio: the Open Source Wealth Management Software](https://github.com/ghostfolio/ghostfolio)** into any _Kubernetes_ cluster. It integrates the official _Docker_ images built by the _Ghostfolio_ team and hosted on _[DockerHub](https://hub.docker.com/r/ghostfolio/ghostfolio)_. It also includes PostgreSQL and [Valkey](https://github.com/valkey-io/valkey-helm) as optional subcharts.

## 0. This is an opinionated fork

This fork has several breaking changes from the [upstream repo](https://github.com/ByTheHugo/ghostfolio-helm)

- Official **Valkey** chart instead of Redis
- Cloudpirates **PostgreSQL** chart instead of Bitnami
- Removed ingress and secrets as out of scope

## 1. Installation

### Prerequisites

- A **Kubernetes** cluster,
- A **PostgreSQL** server (optional),
- A **Valkey** instance (optional),
- The **Helm** client installed locally (see _[Quickstart Guide](https://helm.sh/docs/intro/quickstart/)_),
- The `kubectl` command-line tool installed locally (optional, see _[Install Tools](https://kubernetes.io/docs/tasks/tools/)_)

### Add the GitHub Helm repository

```bash
helm repo add ghostfolio https://j4ns-r.github.io/ghostfolio-helm/
helm repo update
# list versions
helm search repo --versions ghostfolio
```

### Install the chart

First, create one or more secrets for the ghostfolio app. See expected keys below. Secret values can be almost any string. Example: `openssl rand -hex 24`.

Create a values file configuring the chart:

```yaml
# Optional: pin specific ghostfolio image tag. Default is chart appVersion
# image:
#   tag: 1.2.3

ghostfolio:
  existingSecret: gf-secret # keys: JWT_SECRET_KEY, ACCESS_TOKEN_SALT
  ROOT_URL: "http://ghostfolio.ghostfolio.svc.cluster.local"

valkey:
  auth:
    usersExistingSecret: valkey-secret  # key: default

postgres:
  auth:
    existingSecret: pg-secret  # keys: postgres-password, uri
```

```bash
helm upgrade --install ghostfolio ghostfolio/ghostfolio -f values.yaml
```

### Verify the deployment

```bash
kubectl get pods -l app.kubernetes.io/instance=ghostfolio -n <namespace>
# Once all pods are up:
helm test ghostfolio -n <namespace>
```

Replace <namespace> with your target namespace if you specified one.

## 2. Uninstall the chart

```bash
helm uninstall ghostfolio -n <namespace>
```

## 3. License

Distributed under the Apache 2.0 License. See `LICENSE` for more information.

## 4. Contributing

PR's welcome. See `CONTRIBUTING.md`

<p align="right"><a href="#ghostfolio-helm-chart">back to top</a></p>
