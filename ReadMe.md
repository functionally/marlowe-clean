# Advance timed-out Marlowe transactions

Scripts for find and advance all Marlowe transactions that have timed out.


## Build docker image

```bash
podman load < $(nix build --print-out-paths)
podman push localhost/marlowe-clean:latest docker://ghcr.io/functionally/marlowe-clean:latest
```

## Example deployment

```bash
podman play kube --replace=true --start=true example-kube.yaml
``` 
