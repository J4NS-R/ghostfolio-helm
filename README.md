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
  - [1.2. Configure the application](#12-configure-the-application)
    - [1.2.1. Use an external PostgreSQL server](#121-use-an-external-postgresql-server)
    - [1.2.2. Use an external Valkey server](#122-use-an-external-valkey-server)
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
- The `kubectl` command-line tool installed locally (optionnal, see _[Install Tools](https://kubernetes.io/docs/tasks/tools/)_)

## 1.2. Configure the application

Like any other _Helm_ chart, the available configuration options can be found in the `charts/ghostfolio/values.yaml` configuration file. I recommend you to override any values in a dedicated `ghostfolio.values.yaml` file before deploying the chart:

1. Start by retrieving the chart default values: `helm show values charts/ghostfolio > ghostfolio.values.yaml`

2. Edit the `ghostfolio.values.yaml` values, and specially the following ones:

    ```yaml
    ghostfolio:
      existingSecret: "my-ghostfolio-secret"
      BASE_CURRENCY: EUR # or USD

    # For more information checkout: https://github.com/CloudPirates-io/helm-charts/tree/main/charts/postgres
    postgres:
      enabled: true
      auth:
        database: ghostfolio-db
        username: ghostfolio-user
        existingSecret: ""

    # For more information checkout: https://github.com/valkey-io/valkey-helm
    valkey:
      enabled: true
      auth:
        enabled: true
        usersExistingSecret: "my-valkey-secret"
        aclUsers:
          default:
            permissions: "~* &* +@all"
      passwordSecretKey: "default"
    ```

### 1.2.1. Use an external PostgreSQL server

By default, the chart deploys a _PostgreSQL_ server via a subchart dependency. However, if you want to use your own instance, set `postgres.enabled` to `false` and provide `DATABASE_URL` via the `env` block:

```yaml
postgres:
  enabled: false

env:
  - name: DATABASE_URL
    value: "postgresql://user:password@postgres.domain.tld:5432/ghostfolio-db?connect_timeout=300&sslmode=prefer"
```

You can also reference an existing _Kubernetes_ Secret instead of inlining the connection string:

```yaml
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: my-external-pg-secret
        key: uri
```

### 1.2.2. Use an external Valkey server

By default, the chart deploys a _Valkey_ server via a subchart dependency. However, if you want to use your own instance, you can set the following values:

```yaml
valkey:
  enabled: false
externalValkey:
  host: valkey.domain.fqdn
  port: 6379
  existingSecret: "my-valkey-secret"
  existingSecretPasswordKey: "password"
```

**Note:** You must create the Kubernetes Secret containing the password before installing the chart. For example:

```bash
kubectl create secret generic my-valkey-secret --from-literal=password=my-secret-password
```

<p align="right"><a href="#ghostfolio-helm-chart">back to top</a></p>

## 1.3. Install the application

To deploy the application using Helm, follow these steps:

### 1.3.1. Add the GitHub Helm repository (optional)

```bash
helm repo add ghostfolio https://j4ns-r.github.io/ghostfolio-helm/
helm repo update
```

### 1.3.2. Install the chart

```bash
helm upgrade --install ghostfolio ghostfolio/ghostfolio -f ghostfolio.values.yaml
```

You can also install the chart directly from sources:

```bash
helm upgrade --install ghostfolio charts/ghostfolio -f ghostfolio.values.yaml
```

#### 1.3.2.1. Install a specific version of Ghostfolio

If you want to install a specific version of _Ghostfolio_, you must define the `.image.tag` key in the `values.yaml` file or directly inline:

```bash
helm upgrade --install --set "image.tag=2.163.0" ghostfolio ghostfolio/ghostfolio
```

### 1.3.3. Verify the deployment

```bash
kubectl get all -l app=ghostfolio
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
