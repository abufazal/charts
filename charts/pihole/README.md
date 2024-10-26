# Pi-Hole Helm Chart

A helm chart for Pi-Hole, a DNS sinkhole that protects your devices from unwanted content without installing any client-side software.

Source Code can be found here: <https://github.com/pi-hole/pi-hole/>


## Prerequisites

1. [x] Helm **v3 > 3.9.0** [installed](https://helm.sh/docs/using_helm/#installing-helm): `helm version`
2. [x] abufazal's chart repository: `helm repo add myrepo https://abufazal.github.io/charts`

### Additional Prerequisites 
Following list of additional prerequisites needs to be met, when using specific featurs.

#### Additional Prerequisites - HA 
To be able to configure Pi-Hole in HA mode, we would need some kind of persitent volume with `ReadWriteMany` access mode such that the Pi-Hole data can be accessed bu all HA pods simulataneously. 

Ensure following prerequisites are met for HA to work

1. [x] Persistent storage is configured for the kubernetes cluster
2. [x] storageClass is configured to be used for persistent volumes

#### Additional Prerequisites - IngressRoute
If you wish to access the Pi-Hole admin dashboard through `IngressRoute` with a valid SSL certificate, make sure the following prerequisites are met

1. [x] cert-manager is installed on the cluster
2. [x] A valid certificate `issuer` or `ClusterIssuer` is configured on the Kubernetes cluster


## Installing

### Deploying Pi-Hole

```bash
helm install <release_name> <repo_name>/pihole
```

Example:

```bash
helm install dnsPrimary abufazal/pihole
```

You can customize the install with a `values` file.

Complete documentation on all available parameters is in the [default file](values.yaml).

```bash
helm install -f myvalues.yaml dnsPrimary abufazal/pihole
```

## Salient Features
1. [x] Service seggregation for admin dashboard and DNS services
2. [x] Inbuilt support for persistent storage to enable HA
3. [x] Inbuilt support for ingress creation
4. [x] Inbuilt support for SSL/TLS certificate generation
5. [x] Inbuilt support to retain persistent volumes during release upgrades and uninstallation