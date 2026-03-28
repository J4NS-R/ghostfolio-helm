<!-- markdownlint-disable MD033 MD024 -->

[![Latest Tag](https://img.shields.io/github/v/tag/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/tags)
[![Project License](https://img.shields.io/github/license/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/blob/master/LICENSE)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/commits/master/)
[![GitHub Commit Activity](https://img.shields.io/github/commit-activity/m/J4NS-R/ghostfolio-helm)](https://github.com/J4NS-R/ghostfolio-helm/commits/master/)
[![GitHub Repository](https://img.shields.io/badge/GitHub-ghostfolio--helm-lightgrey)](https://github.com/J4NS-R/ghostfolio-helm)

![Ghostfolio Helm banner](docs/ghostfolio-helm-banner.png)

# Unofficial Ghostfolio Helm Chart

This project provides a _Helm_ chart for deploying **[Ghostfolio: the Open Source Wealth Management Software](https://github.com/ghostfolio/ghostfolio)** into any _Kubernetes_ cluster. It integrates the official _Docker_ images built by the _Ghostfolio_ team and hosted on _[DockerHub](https://hub.docker.com/r/ghostfolio/ghostfolio)_. It also includes PostgreSQL and [Valkey](https://github.com/valkey-io/valkey-helm).

The charts are built and then published to these project _GitHub Pages_, allowing anyone to quickly deploy and test the application.

<!-- omit in toc -->
## Table of content

- [Ghostfolio Helm Chart](#ghostfolio-helm-chart)
  - [1.1. Prerequisite](#11-prerequisite)
  - [1.3. Install the application](#13-install-the-application)
    - [1.3.1. Add the GitHub Helm repository (optional)](#131-add-the-github-helm-repository-optional)
    - [1.3.2. Install the chart](#132-install-the-chart)
      - [1.3.2.1. Install a specific version of Ghostfolio](#1321-install-a-specific-version-of-ghostfolio)
    - [1.3.3. Verify the deployment](#133-verify-the-deployment)
  - [1.4. Uninstall the application](#14-uninstall-the-application)
  - [1.5. License](#15-license)

## 1.1. Prerequisite

- A **Kubernetes** cluster,
- A **PostgreSQL** server (optional),
- A **Valkey** instance (optional),
- The **Helm** client installed locally (see _[Quickstart Guide](https://helm.sh/docs/intro/quickstart/)_),
- The `kubectl` command-line tool installed locally (optional, see _[Install Tools](https://kubernetes.io/docs/tasks/tools/)_)

## 1.3. Install the application

To deploy the application using Helm, follow these steps:

### 1.3.1. Add the GitHub Helm repository

```bash
helm repo add ghostfolio https://j4ns-r.github.io/ghostfolio-helm/
helm repo update
# list versions
helm search repo --versions ghostfolio
```

### 1.3.2. Install the chart

First, create one or more secrets for the ghostfolio app. See expected keys below. Secret values can be almost any string. Example: `openssl rand -hex 24`.

Create a values file configuring the chart:

```yaml
ghostfolio:
  existingSecret: gf-secret # keys: JWT_SECRET_KEY, ACCESS_TOKEN_SALT
  ROOT_URL: "http://ghostfolio.ghostfolio.svc.cluster.local"

valkey:
  auth:
    usersExistingSecret: valkey-secret  # key: default

postgres:
  auth:
    existingSecret: pg-secret  # key: postgres-password
```

```bash
helm upgrade --install ghostfolio ghostfolio/ghostfolio -f values.yaml
```

#### 1.3.2.1. Install a specific version of Ghostfolio

If you want to install a specific version of _Ghostfolio_, you must define the `.image.tag` key in the `values.yaml`.

### 1.3.3. Verify the deployment

```bash
kubectl get all -l app.kubernetes.io/instance=ghostfolio
```

Replace <namespace> with your target namespace if you specified one.

<p align="right"><a href="#ghostfolio-helm-chart">back to top</a></p>

## 1.4. Uninstall the application

To uninstall the _Helm_ chart and remove all associated resources from your _Kubernetes_ cluster, follow these steps:

1. Identify the release name you used when installing the chart. If you haven't changed the release name, it may be the default or the one you specified during installation.

2. Run the following command to uninstall the release:

    ```bash
    helm uninstall ghostfolio
    ```

3. Verify that the resources have been removed:

    ```bash
    kubectl get all -l app=ghostfolio
    ```

    This should return no resources related to the uninstalled release.

**Note:** If you used custom namespaces during installation, include the `-n <namespace>` flag in the commands:

```bash
helm uninstall ghostfolio -n <namespace>
kubectl get all -n <namespace> -l app=ghostfolio
```

<p align="right"><a href="#ghostfolio-helm-chart">back to top</a></p>

## 1.5. License

Distributed under the Apache 2.0 License. See `LICENSE` for more information.

<p align="right"><a href="#ghostfolio-helm-chart">back to top</a></p>
