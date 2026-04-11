# Contributing to this project

## Developer guide

### Directories

- `chart/` - chart definition
- `chart/templates/` - manifests to be templated and deployed
- `chart/templates/tests/` - pod to be created on `helm test` (after chart installed)
- `chart/tests/` - helm unittests (not deployed)

### Tools

- helm
- [helm unittest](https://github.com/helm-unittest/helm-unittest)

### Testing

```bash
helm unittest chart
```

[How to write helm unit tests](https://github.com/helm-unittest/helm-unittest/blob/main/DOCUMENT.md)

### Opinionated design

This chart is opinionated in the following ways:

- Creating and managing secrets are out of scope. Chart users are expected to create secrets themselves using sealed secrets, sops, external secrets operator, or any other way. This chart will simply consume those secrets. 
  - Rationale: Allowing passwords as values encourages users to put secrets in non-sensitive places such as `values.yaml` or as `--set` flags in a helm command.
  - Some chart authors opt for generating secrets at the template-level (eg using `randAlphaNum | b64enc`). This is convenient at install-time, but risks data loss if this secret is ever accidentally deleted. In this case the password would be unrecoverable and the data protected by the password would become difficult to access.
- Creating and managing an ingress is out of scope. Since [Kubernetes Ingress is being deprecated](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/), we may add `Gateway` support to the chart in the future.
- We use [cloudpirates postgres](https://github.com/CloudPirates-io/helm-charts/tree/main/charts/postgres) instead of bitnami. Support for cloudnative-pg may be added in the future.
- We use the official [valkey chart](https://github.com/valkey-io/valkey-helm/tree/main/valkey) instead of redis.

### Releasing

#### Stable releases

1. Bump `version` in `chart/Chart.yaml` (e.g. `0.2.0`).
2. Describe changes in `artifacthub.io/changes` annotation in `Chart.yaml`
3. Merge to `master`. The [release workflow](.github/workflows/chart-test-release.yaml) detects the version change, packages the chart, creates a GitHub Release, and updates the Helm repo index on GitHub Pages.

#### Pre-releases

1. Create a `release/*` branch (e.g. `release/0.2.0-rc`).
2. Set `version` in `chart/Chart.yaml` to a SemVer pre-release (e.g. `0.2.0-rc.1`).
3. Push the branch. The release workflow creates a GitHub Release that is not marked as "latest".
4. The chart is published to the Helm repo index, but Helm clients ignore pre-release versions by default. Users must install with `--devel`:
   ```bash
   helm install ghostfolio ghostfolio/ghostfolio --devel
   ```
5. For subsequent pre-releases, bump the version (e.g. `0.2.0-rc.2`) and push again.
