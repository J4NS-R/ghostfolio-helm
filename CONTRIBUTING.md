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
  - Some chart authors opt for generating secrets at the template-level (eg using `randAlphaNum | b64enc`). This is convenient at install-time, but risks data loss if this secret is ever accidentally deleted. In this case the password would be unrecoverable and the data protected by the password would become difficult to recover.  
