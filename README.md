crwctl
======

The [Red Hat CodeReady Workspaces](https://developers.redhat.com/products/codeready-workspaces/overview) CLI for OpenShift 3.11 is `crwctl`.

For OpenShift 4, use the OperatorHub installation method:

https://access.redhat.com/documentation/en-us/red_hat_codeready_workspaces/2.1/html/installation_guide/installing-codeready-workspaces-on-ocp-4#installing-codeready-workspaces-on-openshift-4-from-operatorhub_installing-codeready-workspaces-on-openshift-container-platform-4

[![oclif](https://img.shields.io/badge/cli-oclif-brightgreen.svg)](https://oclif.io)

## Report issues

[Issues are tracked in JIRA](https://issues.jboss.org/browse/CRW-463?jql=project%20%3D%20CRW%20AND%20(component%20%3D%20crwctl%20OR%20labels%20%3D%20crwctl)).

## Table Of Contents

<!-- toc -->
* [Installation](#installation)
* [Usage](#usage)
* [Commands](#commands)
* [Contributing](#contributing)
<!-- tocstop -->
# Installation

Assemblies of crwctl are available at [https://github.com/redhat-developer/codeready-workspaces-chectl/releases](https://github.com/redhat-developer/codeready-workspaces-chectl/releases)

Manual install:

1) Download a .tar.gz file based on your Operating System / Arch 
2) Unpack the assembly
3) move `crwctl` folder into a folder like `$HOME/crwctl`
4) add `$HOME/crwctl/bin` to `$PATH``

# Usage
```sh-session
$ crwctl server:start
running command...

$ crwctl server:stop
running command...

$ crwctl workspace:start --devfile
running command...

$ crwctl --help [COMMAND]
USAGE
  $ crwctl COMMAND
...
```
# Commands
<!-- commands -->
* [`crwctl autocomplete [SHELL]`](#crwctl-autocomplete-shell)
* [`crwctl cacert:export`](#crwctl-cacertexport)
* [`crwctl dashboard:open`](#crwctl-dashboardopen)
* [`crwctl help [COMMAND]`](#crwctl-help-command)
* [`crwctl server:debug`](#crwctl-serverdebug)
* [`crwctl server:delete`](#crwctl-serverdelete)
* [`crwctl server:deploy`](#crwctl-serverdeploy)
* [`crwctl server:logs`](#crwctl-serverlogs)
* [`crwctl server:start`](#crwctl-serverstart)
* [`crwctl server:status`](#crwctl-serverstatus)
* [`crwctl server:stop`](#crwctl-serverstop)
* [`crwctl server:update`](#crwctl-serverupdate)
* [`crwctl update [CHANNEL]`](#crwctl-update-channel)

## `crwctl autocomplete [SHELL]`

display autocomplete installation instructions

```
USAGE
  $ crwctl autocomplete [SHELL]

ARGUMENTS
  SHELL  shell type

OPTIONS
  -r, --refresh-cache  Refresh cache (ignores displaying instructions)

EXAMPLES
  $ crwctl autocomplete
  $ crwctl autocomplete bash
  $ crwctl autocomplete zsh
  $ crwctl autocomplete --refresh-cache
```

_See code: [@oclif/plugin-autocomplete](https://github.com/oclif/plugin-autocomplete/blob/v1.1.1/src/commands/autocomplete/index.ts)_

## `crwctl cacert:export`

Retrieves CodeReady Workspaces self-signed certificate

```
USAGE
  $ crwctl cacert:export

OPTIONS
  -d, --destination=destination
      Destination where to store Che self-signed CA certificate.
      If the destination is a file (might not exist), then the certificate will be saved there in PEM format.
      If the destination is a directory, then cheCA.crt file will be created there with Che certificate in PEM format.
      If this option is omitted, then Che certificate will be stored in a user's temporary directory as cheCA.crt.

  -h, --help
      show CLI help

  -n, --chenamespace=chenamespace
      CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/cacert/export.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.16.0-CI-redhat/src/commands/cacert/export.ts)_

## `crwctl dashboard:open`

Open CodeReady Workspaces dashboard

```
USAGE
  $ crwctl dashboard:open

OPTIONS
  -h, --help                       show CLI help
  -n, --chenamespace=chenamespace  CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'
  --telemetry=on|off               Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/dashboard/open.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.16.0-CI-redhat/src/commands/dashboard/open.ts)_

## `crwctl help [COMMAND]`

display help for crwctl

```
USAGE
  $ crwctl help [COMMAND]

ARGUMENTS
  COMMAND  command to show help for

OPTIONS
  --all  see all commands in CLI
```

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v3.2.18/src/commands/help.ts)_

## `crwctl server:debug`

Enable local debug of CodeReady Workspaces server

```
USAGE
  $ crwctl server:debug

OPTIONS
  -h, --help                       show CLI help
  -n, --chenamespace=chenamespace  CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'
  --debug-port=debug-port          [default: 8000] CodeReady Workspaces server debug port
  --skip-kubernetes-health-check   Skip Kubernetes health check
  --telemetry=on|off               Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/debug.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.16.0-CI-redhat/src/commands/server/debug.ts)_

## `crwctl server:delete`

delete any CodeReady Workspaces related resource: Kubernetes/OpenShift

```
USAGE
  $ crwctl server:delete

OPTIONS
  -h, --help                         show CLI help
  -n, --chenamespace=chenamespace    CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  -y, --yes                          Automatic yes to prompts; assume "yes" as answer to all prompts and run
                                     non-interactively

  --batch                            Batch mode. Running a command without end user interaction.

  --delete-namespace                 Indicates that a CodeReady Workspaces namespace will be deleted as well

  --deployment-name=deployment-name  [default: codeready] CodeReady Workspaces deployment name

  --skip-kubernetes-health-check     Skip Kubernetes health check

  --telemetry=on|off                 Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/delete.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.16.0-CI-redhat/src/commands/server/delete.ts)_

## `crwctl server:deploy`

Deploy CodeReady Workspaces server

```
USAGE
  $ crwctl server:deploy

OPTIONS
  -a, --installer=operator|olm
      Installer type. If not set, default is "olm" for OpenShift 4.x platform otherwise "operator".

  -d, --directory=directory
      Directory to store logs into

  -h, --help
      show CLI help

  -i, --cheimage=cheimage
      CodeReady Workspaces server container image

  -n, --chenamespace=chenamespace
      CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  -o, --cheboottimeout=cheboottimeout
      (required) [default: 40000] CodeReady Workspaces server bootstrap timeout (in milliseconds)

  -p, --platform=openshift|crc
      [default: openshift] Type of OpenShift platform. Valid values are "openshift", "crc (for CodeReady Containers)".

  -t, --templates=templates
      Path to the templates folder

  --[no-]auto-update
      Auto update approval strategy for installation CodeReady Workspaces.
      With this strategy will be provided auto-update CodeReady Workspaces without any human interaction.
      By default this flag is enabled.
      This parameter is used only when the installer is 'olm'.

  --batch
      Batch mode. Running a command without end user interaction.

  --catalog-source-name=catalog-source-name
      OLM catalog source to install CodeReady Workspaces operator.
      This parameter is used only when the installer is the 'olm'.

  --catalog-source-namespace=catalog-source-namespace
      Namespace for OLM catalog source to install CodeReady Workspaces operator.
      This parameter is used only when the installer is the 'olm'.

  --catalog-source-yaml=catalog-source-yaml
      Path to a yaml file that describes custom catalog source for installation CodeReady Workspaces operator.
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
      Enable cluster monitoring to scrape CodeReady Workspaces metrics in Prometheus.
      This parameter is used only when the platform is 'openshift'.

  --debug
      Enables the debug mode for CodeReady Workspaces server. To debug CodeReady Workspaces server from localhost use
      'server:debug' command.

  --deployment-name=deployment-name
      [default: codeready] CodeReady Workspaces deployment name

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
      Olm channel to install CodeReady Workspaces, f.e. stable.
      If options was not set, will be used default version for package manifest.
      This parameter is used only when the installer is the 'olm'.

  --[no-]olm-suggested-namespace
      Indicate to deploy CodeReady Workspaces in OLM suggested namespace: 'openshift-workspaces'.
      Flag 'chenamespace' is ignored in this case
      This parameter is used only when the installer is 'olm'.

  --package-manifest-name=package-manifest-name
      Package manifest name to subscribe to CodeReady Workspaces OLM package manifest.
      This parameter is used only when the installer is the 'olm'.

  --plugin-registry-url=plugin-registry-url
      The URL of the external plugin registry.

  --postgres-pvc-storage-class-name=postgres-pvc-storage-class-name
      persistent volume storage class name to use to store CodeReady Workspaces postgres database

  --skip-cluster-availability-check
      Skip cluster availability check. The check is a simple request to ensure the cluster is reachable.

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --skip-oidc-provider-check
      Skip OIDC Provider check

  --skip-version-check
      Skip minimal versions check.

  --starting-csv=starting-csv
      Starting cluster service version(CSV) for installation CodeReady Workspaces.
      Flags uses to set up start installation version Che.
      For example: 'starting-csv' provided with value 'eclipse-che.v7.10.0' for stable channel.
      Then OLM will install CodeReady Workspaces with version 7.10.0.
      Notice: this flag will be ignored with 'auto-update' flag. OLM with auto-update mode installs the latest known
      version.
      This parameter is used only when the installer is 'olm'.

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry

  --workspace-pvc-storage-class-name=workspace-pvc-storage-class-name
      persistent volume(s) storage class name to use to store CodeReady Workspaces workspaces data
```

_See code: [src/commands/server/deploy.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.16.0-CI-redhat/src/commands/server/deploy.ts)_

## `crwctl server:logs`

Collect CodeReady Workspaces logs

```
USAGE
  $ crwctl server:logs

OPTIONS
  -d, --directory=directory          Directory to store logs into
  -h, --help                         show CLI help
  -n, --chenamespace=chenamespace    CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'
  --deployment-name=deployment-name  [default: codeready] CodeReady Workspaces deployment name
  --skip-kubernetes-health-check     Skip Kubernetes health check
  --telemetry=on|off                 Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/logs.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.16.0-CI-redhat/src/commands/server/logs.ts)_

## `crwctl server:start`

Start CodeReady Workspaces server

```
USAGE
  $ crwctl server:start

OPTIONS
  -d, --directory=directory                                Directory to store logs into
  -h, --help                                               show CLI help

  -n, --chenamespace=chenamespace                          CodeReady Workspaces Openshift Project. Default to
                                                           'openshift-workspaces'

  --batch                                                  Batch mode. Running a command without end user interaction.

  --deployment-name=deployment-name                        [default: codeready] CodeReady Workspaces deployment name

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

_See code: [src/commands/server/start.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.16.0-CI-redhat/src/commands/server/start.ts)_

## `crwctl server:status`

Status CodeReady Workspaces server

```
USAGE
  $ crwctl server:status

OPTIONS
  -h, --help                       show CLI help
  -n, --chenamespace=chenamespace  CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'
  --telemetry=on|off               Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/status.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.16.0-CI-redhat/src/commands/server/status.ts)_

## `crwctl server:stop`

stop CodeReady Workspaces server

```
USAGE
  $ crwctl server:stop

OPTIONS
  -h, --help                         show CLI help
  -n, --chenamespace=chenamespace    CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  --access-token=access-token        CodeReady Workspaces OIDC Access Token. See the documentation how to obtain token:
                                     https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#o
                                     btaining-the-token-from-keycloak_authenticating-to-the-che-server and https://www.e
                                     clipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-
                                     token-from-openshift-token-through-keycloak_authenticating-to-the-che-server.

  --che-selector=che-selector        [default: app=codeready,component=codeready] Selector for CodeReady Workspaces
                                     server resources

  --deployment-name=deployment-name  [default: codeready] CodeReady Workspaces deployment name

  --skip-kubernetes-health-check     Skip Kubernetes health check

  --telemetry=on|off                 Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/stop.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.16.0-CI-redhat/src/commands/server/stop.ts)_

## `crwctl server:update`

Update CodeReady Workspaces server.

```
USAGE
  $ crwctl server:update

OPTIONS
  -h, --help                                               show CLI help

  -n, --chenamespace=chenamespace                          CodeReady Workspaces Openshift Project. Default to
                                                           'openshift-workspaces'

  -p, --platform=openshift|crc                             [default: openshift] Type of OpenShift platform. Valid values
                                                           are "openshift", "crc (for CodeReady Containers)".

  -t, --templates=templates                                Path to the templates folder

  -y, --yes                                                Automatic yes to prompts; assume "yes" as answer to all
                                                           prompts and run non-interactively

  --batch                                                  Batch mode. Running a command without end user interaction.

  --che-operator-cr-patch-yaml=che-operator-cr-patch-yaml  Path to a yaml file that overrides the default values in
                                                           CheCluster CR used by the operator. This parameter is used
                                                           only when the installer is the 'operator' or the 'olm'.

  --deployment-name=deployment-name                        [default: codeready] CodeReady Workspaces deployment name

  --skip-kubernetes-health-check                           Skip Kubernetes health check

  --telemetry=on|off                                       Enable or disable telemetry. This flag skips a prompt and
                                                           enable/disable telemetry

EXAMPLES
  # Update CodeReady Workspaces:
  crwctl server:update

  # Update CodeReady Workspaces in 'eclipse-che' namespace:
  crwctl server:update -n eclipse-che

  # Update CodeReady Workspaces and update its configuration in the custom resource:
  crwctl server:update --che-operator-cr-patch-yaml patch.yaml
```

_See code: [src/commands/server/update.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.16.0-CI-redhat/src/commands/server/update.ts)_

## `crwctl update [CHANNEL]`

update the crwctl CLI

```
USAGE
  $ crwctl update [CHANNEL]

OPTIONS
  --from-local  interactively choose an already installed version
```

_See code: [@oclif/plugin-update](https://github.com/oclif/plugin-update/blob/v1.5.0/src/commands/update.ts)_
<!-- commandsstop -->

# Contributing

Contributing to crwctl is covered in [CONTRIBUTING.md](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/master/CONTRIBUTING.md)
