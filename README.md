dsc
======

The [Red Hat OpenShift Dev Spaces (formerly Red Hat OpenShift Dev Spaces)](https://developers.redhat.com/products/codeready-workspaces/overview) CLI for OpenShift is `dsc`.

For OpenShift 4, can also use the OperatorHub installation method:

https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.0/html/installation_guide/installing-codeready-workspaces-on-ocp-4#installing-codeready-workspaces-on-openshift-4-from-operatorhub_installing-codeready-workspaces-on-openshift-container-platform-4

[![oclif](https://img.shields.io/badge/cli-oclif-brightgreen.svg)](https://oclif.io)

## Report issues

[Issues are tracked in JIRA](https://issues.jboss.org/browse/CRW-463?jql=project%20%3D%20CRW%20AND%20(component%20%3D%20dsc%20OR%20labels%20%3D%20dsc)).

## Table Of Contents

<!-- toc -->
* [Installation](#installation)
* [Usage](#usage)
* [Commands](#commands)
* [Contributing](#contributing)
<!-- tocstop -->
# Installation

Assemblies of dsc are available at [https://github.com/redhat-developer/devspaces-chectl/releases](https://github.com/redhat-developer/devspaces-chectl/releases)

Manual install:

1) Download a .tar.gz file based on your Operating System / Arch 
2) Unpack the assembly
3) move `dsc` folder into a folder like `$HOME/dsc`
4) add `$HOME/dsc/bin` to `$PATH``

# Usage
```sh-session
$ dsc server:start
running command...

$ dsc server:stop
running command...

$ dsc workspace:start --devfile
running command...

$ dsc --help [COMMAND]
USAGE
  $ dsc COMMAND
...
```
# Commands
<!-- commands -->
* [`dsc autocomplete [SHELL]`](#dsc-autocomplete-shell)
* [`dsc cacert:export`](#dsc-cacertexport)
* [`dsc dashboard:open`](#dsc-dashboardopen)
* [`dsc help [COMMAND]`](#dsc-help-command)
* [`dsc server:debug`](#dsc-serverdebug)
* [`dsc server:delete`](#dsc-serverdelete)
* [`dsc server:deploy`](#dsc-serverdeploy)
* [`dsc server:logs`](#dsc-serverlogs)
* [`dsc server:start`](#dsc-serverstart)
* [`dsc server:status`](#dsc-serverstatus)
* [`dsc server:stop`](#dsc-serverstop)
* [`dsc server:update`](#dsc-serverupdate)
* [`dsc update [CHANNEL]`](#dsc-update-channel)

## `dsc autocomplete [SHELL]`

display autocomplete installation instructions

```
USAGE
  $ dsc autocomplete [SHELL]

ARGUMENTS
  SHELL  shell type

OPTIONS
  -r, --refresh-cache  Refresh cache (ignores displaying instructions)

EXAMPLES
  $ dsc autocomplete
  $ dsc autocomplete bash
  $ dsc autocomplete zsh
  $ dsc autocomplete --refresh-cache
```

_See code: [@oclif/plugin-autocomplete](https://github.com/oclif/plugin-autocomplete/blob/v1.3.0/src/commands/autocomplete/index.ts)_

## `dsc cacert:export`

Retrieves Red Hat OpenShift Dev Spaces self-signed certificate

```
USAGE
  $ dsc cacert:export

OPTIONS
  -d, --destination=destination
      Destination where to store Che self-signed CA certificate.
      If the destination is a file (might not exist), then the certificate will be saved there in PEM format.
      If the destination is a directory, then cheCA.crt file will be created there with Che certificate in PEM format.
      If this option is omitted, then Che certificate will be stored in a user's temporary directory as cheCA.crt.

  -h, --help
      show CLI help

  -n, --chenamespace=chenamespace
      Red Hat OpenShift Dev Spaces Openshift Project. Default to 'openshift-devspaces'

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/cacert/export.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.1.0-CI-a165-redhat/src/commands/cacert/export.ts)_

## `dsc dashboard:open`

Open Red Hat OpenShift Dev Spaces dashboard

```
USAGE
  $ dsc dashboard:open

OPTIONS
  -h, --help                       show CLI help
  -n, --chenamespace=chenamespace  Red Hat OpenShift Dev Spaces Openshift Project. Default to 'openshift-devspaces'
  --telemetry=on|off               Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/dashboard/open.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.1.0-CI-a165-redhat/src/commands/dashboard/open.ts)_

## `dsc help [COMMAND]`

Display help for dsc.

```
USAGE
  $ dsc help [COMMAND]

ARGUMENTS
  COMMAND  Command to show help for.

OPTIONS
  -n, --nested-commands  Include all nested commands in the output.
```

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v5.1.12/src/commands/help.ts)_

## `dsc server:debug`

Enable local debug of Red Hat OpenShift Dev Spaces server

```
USAGE
  $ dsc server:debug

OPTIONS
  -h, --help                       show CLI help
  -n, --chenamespace=chenamespace  Red Hat OpenShift Dev Spaces Openshift Project. Default to 'openshift-devspaces'
  --debug-port=debug-port          [default: 8000] Red Hat OpenShift Dev Spaces server debug port
  --skip-kubernetes-health-check   Skip Kubernetes health check
  --telemetry=on|off               Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/debug.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.1.0-CI-a165-redhat/src/commands/server/debug.ts)_

## `dsc server:delete`

delete any Red Hat OpenShift Dev Spaces related resource

```
USAGE
  $ dsc server:delete

OPTIONS
  -h, --help                       show CLI help
  -n, --chenamespace=chenamespace  Red Hat OpenShift Dev Spaces Openshift Project. Default to 'openshift-devspaces'

  -y, --yes                        Automatic yes to prompts; assume "yes" as answer to all prompts and run
                                   non-interactively

  --batch                          Batch mode. Running a command without end user interaction.

  --delete-namespace               Indicates that a Red Hat OpenShift Dev Spaces namespace will be deleted as well

  --skip-kubernetes-health-check   Skip Kubernetes health check

  --telemetry=on|off               Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/delete.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.1.0-CI-a165-redhat/src/commands/server/delete.ts)_

## `dsc server:deploy`

Deploy Red Hat OpenShift Dev Spaces server

```
USAGE
  $ dsc server:deploy

OPTIONS
  -a, --installer=olm|operator
      Installer type. If not set, default is olm for OpenShift >= 4.2, and operator for earlier versions.

  -d, --directory=directory
      Directory to store logs into

  -h, --help
      show CLI help

  -i, --cheimage=cheimage
      Red Hat OpenShift Dev Spaces server container image

  -n, --chenamespace=chenamespace
      Red Hat OpenShift Dev Spaces Openshift Project. Default to 'openshift-devspaces'

  -o, --cheboottimeout=cheboottimeout
      (required) [default: 40000] Red Hat OpenShift Dev Spaces server bootstrap timeout (in milliseconds)

  -p, --platform=openshift|crc
      [default: openshift] Type of OpenShift platform. Valid values are "openshift", "crc (for CodeReady Containers)".

  -t, --templates=templates
      Path to the templates folder

  --[no-]auto-update
      Auto update approval strategy for installation Red Hat OpenShift Dev Spaces.
      With this strategy will be provided auto-update Red Hat OpenShift Dev Spaces without any human interaction.
      By default this flag is enabled.
      This parameter is used only when the installer is 'olm'.

  --batch
      Batch mode. Running a command without end user interaction.

  --catalog-source-name=catalog-source-name
      OLM catalog source to install Red Hat OpenShift Dev Spaces operator.
      This parameter is used only when the installer is the 'olm'.

  --catalog-source-namespace=catalog-source-namespace
      Namespace for OLM catalog source to install Red Hat OpenShift Dev Spaces operator.
      This parameter is used only when the installer is the 'olm'.

  --catalog-source-yaml=catalog-source-yaml
      Path to a yaml file that describes custom catalog source for installation Red Hat OpenShift Dev Spaces operator.
      Catalog source will be applied to the namespace with Che operator.
      Also you need define 'olm-channel' name and 'package-manifest-name'.
      This parameter is used only when the installer is the 'olm'.

  --che-operator-cr-patch-yaml=che-operator-cr-patch-yaml
      Path to a yaml file that overrides the default values in CheCluster CR used by the operator. This parameter is used
      only when the installer is the 'operator' or the 'olm'.

  --che-operator-cr-yaml=che-operator-cr-yaml
      Path to a yaml file that defines a CheCluster used by the operator. This parameter is used only when the installer
      is the 'operator' or the 'olm'.

  --che-operator-image=che-operator-image
      Container image of the operator. This parameter is used only when the installer is the operator or OLM.

  --cluster-monitoring
      Enable cluster monitoring to scrape Red Hat OpenShift Dev Spaces metrics in Prometheus.
      This parameter is used only when the platform is 'openshift'.

  --debug
      Enables the debug mode for Red Hat OpenShift Dev Spaces server. To debug Red Hat OpenShift Dev Spaces server from
      localhost use 'server:debug' command.

  --devfile-registry-url=devfile-registry-url
      The URL of the external Devfile registry.

  --k8spoddownloadimagetimeout=k8spoddownloadimagetimeout
      [default: 600000] Waiting time for Pod downloading image (in milliseconds)

  --k8spoderrorrechecktimeout=k8spoderrorrechecktimeout
      [default: 60000] Waiting time for Pod rechecking error (in milliseconds)

  --k8spodreadytimeout=k8spodreadytimeout
      [default: 600000] Waiting time for Pod Ready condition (in milliseconds)

  --k8spodwaittimeout=k8spodwaittimeout
      [default: 600000] Waiting time for Pod scheduled condition (in milliseconds)

  --olm-channel=olm-channel
      Olm channel to install Red Hat OpenShift Dev Spaces, f.e. stable.
      If options was not set, will be used default version for package manifest.
      This parameter is used only when the installer is the 'olm'.

  --package-manifest-name=package-manifest-name
      Package manifest name to subscribe to Red Hat OpenShift Dev Spaces OLM package manifest.
      This parameter is used only when the installer is the 'olm'.

  --plugin-registry-url=plugin-registry-url
      The URL of the external plugin registry.

  --postgres-pvc-storage-class-name=postgres-pvc-storage-class-name
      persistent volume storage class name to use to store Red Hat OpenShift Dev Spaces postgres database

  --skip-cert-manager
      Skip installing Cert Manager on the Kubernetes cluster.

  --skip-cluster-availability-check
      Skip cluster availability check. The check is a simple request to ensure the cluster is reachable.

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --skip-oidc-provider-check
      Skip OIDC Provider check

  --skip-version-check
      Skip minimal versions check.

  --starting-csv=starting-csv
      Starting cluster service version(CSV) for installation Red Hat OpenShift Dev Spaces.
      Flags uses to set up start installation version Che.
      For example: 'starting-csv' provided with value 'eclipse-che.v7.10.0' for stable channel.
      Then OLM will install Red Hat OpenShift Dev Spaces with version 7.10.0.
      Notice: this flag will be ignored with 'auto-update' flag. OLM with auto-update mode installs the latest known
      version.
      This parameter is used only when the installer is 'olm'.

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry

  --workspace-pvc-storage-class-name=workspace-pvc-storage-class-name
      persistent volume(s) storage class name to use to store Red Hat OpenShift Dev Spaces workspaces data
```

_See code: [src/commands/server/deploy.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.1.0-CI-a165-redhat/src/commands/server/deploy.ts)_

## `dsc server:logs`

Collect Red Hat OpenShift Dev Spaces logs

```
USAGE
  $ dsc server:logs

OPTIONS
  -d, --directory=directory        Directory to store logs into
  -h, --help                       show CLI help
  -n, --chenamespace=chenamespace  Red Hat OpenShift Dev Spaces Openshift Project. Default to 'openshift-devspaces'
  --skip-kubernetes-health-check   Skip Kubernetes health check
  --telemetry=on|off               Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/logs.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.1.0-CI-a165-redhat/src/commands/server/logs.ts)_

## `dsc server:start`

Start Red Hat OpenShift Dev Spaces server

```
USAGE
  $ dsc server:start

OPTIONS
  -d, --directory=directory                                Directory to store logs into
  -h, --help                                               show CLI help

  -n, --chenamespace=chenamespace                          Red Hat OpenShift Dev Spaces Openshift Project. Default to
                                                           'openshift-devspaces'

  --batch                                                  Batch mode. Running a command without end user interaction.

  --k8spoddownloadimagetimeout=k8spoddownloadimagetimeout  [default: 600000] Waiting time for Pod downloading image (in
                                                           milliseconds)

  --k8spoderrorrechecktimeout=k8spoderrorrechecktimeout    [default: 60000] Waiting time for Pod rechecking error (in
                                                           milliseconds)

  --k8spodreadytimeout=k8spodreadytimeout                  [default: 600000] Waiting time for Pod Ready condition (in
                                                           milliseconds)

  --k8spodwaittimeout=k8spodwaittimeout                    [default: 600000] Waiting time for Pod scheduled condition
                                                           (in milliseconds)

  --skip-kubernetes-health-check                           Skip Kubernetes health check
```

_See code: [src/commands/server/start.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.1.0-CI-a165-redhat/src/commands/server/start.ts)_

## `dsc server:status`

Status Red Hat OpenShift Dev Spaces server

```
USAGE
  $ dsc server:status

OPTIONS
  -h, --help                       show CLI help
  -n, --chenamespace=chenamespace  Red Hat OpenShift Dev Spaces Openshift Project. Default to 'openshift-devspaces'
  --telemetry=on|off               Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/status.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.1.0-CI-a165-redhat/src/commands/server/status.ts)_

## `dsc server:stop`

stop Red Hat OpenShift Dev Spaces server

```
USAGE
  $ dsc server:stop

OPTIONS
  -h, --help                       show CLI help
  -n, --chenamespace=chenamespace  Red Hat OpenShift Dev Spaces Openshift Project. Default to 'openshift-devspaces'

  --che-selector=che-selector      [default: app=devspaces,component=devspaces] Selector for Red Hat OpenShift Dev
                                   Spaces server resources

  --skip-kubernetes-health-check   Skip Kubernetes health check

  --telemetry=on|off               Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/stop.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.1.0-CI-a165-redhat/src/commands/server/stop.ts)_

## `dsc server:update`

Update Red Hat OpenShift Dev Spaces server.

```
USAGE
  $ dsc server:update

OPTIONS
  -a, --installer=olm|operator                             Installer type. If not set, default is olm for OpenShift >=
                                                           4.2, and operator for earlier versions.

  -h, --help                                               show CLI help

  -n, --chenamespace=chenamespace                          Red Hat OpenShift Dev Spaces Openshift Project. Default to
                                                           'openshift-devspaces'

  -t, --templates=templates                                Path to the templates folder

  -y, --yes                                                Automatic yes to prompts; assume "yes" as answer to all
                                                           prompts and run non-interactively

  --batch                                                  Batch mode. Running a command without end user interaction.

  --che-operator-cr-patch-yaml=che-operator-cr-patch-yaml  Path to a yaml file that overrides the default values in
                                                           CheCluster CR used by the operator. This parameter is used
                                                           only when the installer is the 'operator' or the 'olm'.

  --skip-kubernetes-health-check                           Skip Kubernetes health check

  --telemetry=on|off                                       Enable or disable telemetry. This flag skips a prompt and
                                                           enable/disable telemetry

EXAMPLES
  # Update Red Hat OpenShift Dev Spaces:
  dsc server:update

  # Update Red Hat OpenShift Dev Spaces in 'eclipse-che' namespace:
  dsc server:update -n eclipse-che

  # Update Red Hat OpenShift Dev Spaces and update its configuration in the custom resource:
  dsc server:update --che-operator-cr-patch-yaml patch.yaml
```

_See code: [src/commands/server/update.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.1.0-CI-a165-redhat/src/commands/server/update.ts)_

## `dsc update [CHANNEL]`

update the dsc CLI

```
USAGE
  $ dsc update [CHANNEL]

OPTIONS
  --from-local  interactively choose an already installed version
```

_See code: [@oclif/plugin-update](https://github.com/oclif/plugin-update/blob/v1.5.0/src/commands/update.ts)_
<!-- commandsstop -->

# Contributing

Contributing to dsc is covered in [CONTRIBUTING.md](https://github.com/redhat-developer/devspaces-chectl/blob/master/CONTRIBUTING.md)
