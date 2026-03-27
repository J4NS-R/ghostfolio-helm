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
