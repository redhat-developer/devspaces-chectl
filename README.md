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
* [`crwctl devfile:generate`](#crwctl-devfilegenerate)
* [`crwctl help [COMMAND]`](#crwctl-help-command)
* [`crwctl server:debug`](#crwctl-serverdebug)
* [`crwctl server:delete`](#crwctl-serverdelete)
* [`crwctl server:logs`](#crwctl-serverlogs)
* [`crwctl server:start`](#crwctl-serverstart)
* [`crwctl server:stop`](#crwctl-serverstop)
* [`crwctl server:update`](#crwctl-serverupdate)
* [`crwctl update`](#crwctl-update)
* [`crwctl workspace:create`](#crwctl-workspacecreate)
* [`crwctl workspace:delete WORKSPACE`](#crwctl-workspacedelete-workspace)
* [`crwctl workspace:inject`](#crwctl-workspaceinject)
* [`crwctl workspace:list`](#crwctl-workspacelist)
* [`crwctl workspace:logs`](#crwctl-workspacelogs)
* [`crwctl workspace:start WORKSPACE`](#crwctl-workspacestart-workspace)
* [`crwctl workspace:stop WORKSPACE`](#crwctl-workspacestop-workspace)

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

_See code: [@oclif/plugin-autocomplete](https://github.com/oclif/plugin-autocomplete/blob/v0.1.5/src/commands/autocomplete/index.ts)_

## `crwctl cacert:export`

Retrieves CodeReady Workspaces self-signed certificate

```
USAGE
  $ crwctl cacert:export

OPTIONS
  -d, --destination=destination
      Destination where to store Che self-signed CA certificate.
                           If the destination is a file (might not exist), then the certificate will be saved there in PEM 
      format.
                           If the destination is a directory, then cheCA.crt file will be created there with Che 
      certificate in PEM format.
                           If this option is ommited, then Che certificate will be stored in user's home directory as 
      cheCA.crt

  -h, --help
      show CLI help

  -n, --chenamespace=chenamespace
      [default: workspaces] Kubernetes namespace where CodeReady Workspaces server is supposed to be deployed

  --skip-kubernetes-health-check
      Skip Kubernetes health check
```

_See code: [src/commands/cacert/export.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/cacert/export.ts)_

## `crwctl dashboard:open`

Open CodeReady Workspaces dashboard

```
USAGE
  $ crwctl dashboard:open

OPTIONS
  -h, --help                       show CLI help

  -n, --chenamespace=chenamespace  [default: workspaces] Kubernetes namespace where CodeReady Workspaces server is
                                   supposed to be deployed
```

_See code: [src/commands/dashboard/open.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/dashboard/open.ts)_

## `crwctl devfile:generate`

generate and print a devfile to stdout given some Kubernetes resources and other workspaces features (project, language-support, commands etc...)

```
USAGE
  $ crwctl devfile:generate

OPTIONS
  -h, --help                 show CLI help
  --command=command          Command to include in the workspace
  --dockerimage=dockerimage  dockerimage component to include in the Devfile
  --editor=editor            Specify the editor component. Currently supported editors: theia-next,theia-1.0.0
  --git-repo=git-repo        Source code git repository to include in the workspace

  --language=language        Add support for a particular language. Currently supported languages:
                             java,typescript,go,python,c#

  --name=name                Workspace name

  --namespace=namespace      Kubernetes namespace where the resources are defined

  --plugin=plugin            CodeReady Workspaces plugin to include in the workspace. The format is JSON. For example
                             this is a valid CodeReady Workspaces plugin specification: {"type":
                             "TheEndpointName.ChePlugin", "alias": "java-ls", "id": "redhat/java/0.38.0"}

  --selector=selector        label selector to filter the Kubernetes resources. For example
                             --selector="app.kubernetes.io/name=employee-manager"
```

_See code: [src/commands/devfile/generate.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/devfile/generate.ts)_

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

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v2.2.3/src/commands/help.ts)_

## `crwctl server:debug`

Enable local debug of CodeReady Workspaces server

```
USAGE
  $ crwctl server:debug

OPTIONS
  -h, --help                               show CLI help

  -n, --chenamespace=chenamespace          [default: workspaces] Kubernetes namespace where CodeReady Workspaces server
                                           is supposed to be deployed

  --debug-port=debug-port                  [default: 8000] CodeReady Workspaces server debug port

  --listr-renderer=default|silent|verbose  [default: default] Listr renderer

  --skip-kubernetes-health-check           Skip Kubernetes health check
```

_See code: [src/commands/server/debug.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/server/debug.ts)_

## `crwctl server:delete`

delete any CodeReady Workspaces related resource

```
USAGE
  $ crwctl server:delete

OPTIONS
  -h, --help                               show CLI help

  -n, --chenamespace=chenamespace          [default: workspaces] Kubernetes namespace where CodeReady Workspaces server
                                           is supposed to be deployed

  --deployment-name=deployment-name        [default: codeready] CodeReady Workspaces deployment name

  --listr-renderer=default|silent|verbose  [default: default] Listr renderer

  --skip-deletion-check                    Skip user confirmation on deletion check

  --skip-kubernetes-health-check           Skip Kubernetes health check
```

_See code: [src/commands/server/delete.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/server/delete.ts)_

## `crwctl server:logs`

Collect CodeReady Workspaces logs

```
USAGE
  $ crwctl server:logs

OPTIONS
  -d, --directory=directory                Directory to store logs into
  -h, --help                               show CLI help

  -n, --chenamespace=chenamespace          [default: workspaces] Kubernetes namespace where CodeReady Workspaces server
                                           is supposed to be deployed

  --deployment-name=deployment-name        [default: codeready] CodeReady Workspaces deployment name

  --listr-renderer=default|silent|verbose  [default: default] Listr renderer

  --skip-kubernetes-health-check           Skip Kubernetes health check
```

_See code: [src/commands/server/logs.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/server/logs.ts)_

## `crwctl server:start`

start CodeReady Workspaces server

```
USAGE
  $ crwctl server:start

OPTIONS
  -a, --installer=operator|olm
      [default: operator] Installer type

  -b, --domain=domain
      Domain of the Kubernetes cluster (e.g. example.k8s-cluster.com or <local-ip>.nip.io)
                           This flag makes sense only for Kubernetes family infrastructures and will be autodetected for 
      Minikube and MicroK8s in most cases.
                           However, for Kubernetes cluster it is required to specify.
                           Please note, that just setting this flag will not likely work out of the box.
                           According changes should be done in Kubernetes cluster configuration as well.
                           In case of Openshift, domain adjustment should be done on the cluster configuration level.

  -d, --directory=directory
      Directory to store logs into

  -h, --help
      show CLI help

  -i, --cheimage=cheimage
      [default: registry.redhat.io/codeready-workspaces/server-rhel8:2.2] CodeReady Workspaces server container image

  -m, --multiuser
      Starts CodeReady Workspaces in multi-user mode

  -n, --chenamespace=chenamespace
      [default: workspaces] Kubernetes namespace where CodeReady Workspaces server is supposed to be deployed

  -o, --cheboottimeout=cheboottimeout
      (required) [default: 40000] CodeReady Workspaces server bootstrap timeout (in milliseconds)

  -p, --platform=openshift|crc
      [default: openshift] Type of OpenShift platform. Valid values are "openshift", "crc (for CodeReady Containers)".

  -s, --tls
      Enable TLS encryption.
                           Note, this option is turned on by default.
                           For Kubernetes infrastructure, it is required to provide own certificate: 'che-tls' secret with 
      TLS certificate must be pre-created in the configured namespace.
                           The only exception is Helm installer. In that case the secret will be generated automatically.
                           For OpenShift, router will use default cluster certificates.
                           If the certificate is self-signed, '--self-signed-cert' option should be provided, otherwise 
      Che won't be able to start.
                           Please see docs for more details: 
      https://www.eclipse.org/che/docs/che-7/installing-che-in-tls-mode-with-self-signed-certificates/

  -t, --templates=templates
      Path to the templates folder

  --auto-update
      Auto update approval strategy for installation CodeReady Workspaces.
                           With this strategy will be provided auto-update CodeReady Workspaces without any human 
      interaction.
                           By default strategy this flag is false. It requires approval from user.
                           To approve installation newer version CodeReady Workspaces user should execute 'crwctl 
      server:update' command.
                           This parameter is used only when the installer is 'olm'.

  --catalog-source-yaml=catalog-source-yaml
      Path to a yaml file that describes custom catalog source for installation CodeReady Workspaces operator.
                           Catalog source will be applied to the namespace with Che operator.
                           Also you need define 'olm-channel' name and 'package-manifest-name'.
                           This parameter is used only when the installer is the 'olm'.

  --che-operator-cr-patch-yaml=che-operator-cr-patch-yaml
      Path to a yaml file that overrides the default values in CheCluster CR used by the operator. This parameter is used 
      only when the installer is the operator.

  --che-operator-cr-yaml=che-operator-cr-yaml
      Path to a yaml file that defines a CheCluster used by the operator. This parameter is used only when the installer 
      is the operator.

  --che-operator-image=che-operator-image
      [default: registry.redhat.io/codeready-workspaces/crw-2-rhel8-operator:2.2] Container image of the operator. This 
      parameter is used only when the installer is the operator

  --debug
      Enables the debug mode for CodeReady Workspaces server. To debug CodeReady Workspaces server from localhost use 
      'server:debug' command.

  --deployment-name=deployment-name
      [default: codeready] CodeReady Workspaces deployment name

  --devfile-registry-url=devfile-registry-url
      The URL of the external Devfile registry.

  --k8spodreadytimeout=k8spodreadytimeout
      [default: 130000] Waiting time for Pod Ready Kubernetes (in milliseconds)

  --k8spodwaittimeout=k8spodwaittimeout
      [default: 300000] Waiting time for Pod Wait Timeout Kubernetes (in milliseconds)

  --listr-renderer=default|silent|verbose
      [default: default] Listr renderer

  --olm-channel=olm-channel
      Olm channel to install CodeReady Workspaces, f.e. stable.
                           If options was not set, will be used default version for package manifest.
                           This parameter is used only when the installer is the 'olm'.

  --os-oauth
      Enable use of OpenShift credentials to log into CodeReady Workspaces

  --package-manifest-name=package-manifest-name
      Package manifest name to subscribe to CodeReady Workspaces OLM package manifest.
                           This parameter is used only when the installer is the 'olm'.

  --plugin-registry-url=plugin-registry-url
      The URL of the external plugin registry.

  --postgres-pvc-storage-class-name=postgres-pvc-storage-class-name
      persistent volume storage class name to use to store CodeReady Workspaces postgres database

  --self-signed-cert
      Authorize usage of self signed certificates for encryption.
                           This is the flag for CodeReady Workspaces to propagate the certificate to components, so they 
      will trust it.
                           Note that `che-tls` secret with CA certificate must be created in the configured namespace.

  --skip-cluster-availability-check
      Skip cluster availability check. The check is a simple request to ensure the cluster is reachable.

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --skip-version-check
      Skip minimal versions check.

  --starting-csv=starting-csv
      Starting cluster service version(CSV) for installation CodeReady Workspaces.
                           Flags uses to set up start installation version Che.
                           For example: 'starting-csv' provided with value 'eclipse-che.v7.10.0' for stable channel.
                           Then OLM will install CodeReady Workspaces with version 7.10.0.
                           Notice: this flag will be ignored with 'auto-update' flag. OLM with auto-update mode installs 
      the latest known version.
                           This parameter is used only when the installer is 'olm'.

  --workspace-pvc-storage-class-name=workspace-pvc-storage-class-name
      persistent volume(s) storage class name to use to store CodeReady Workspaces workspaces data
```

_See code: [src/commands/server/start.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/server/start.ts)_

## `crwctl server:stop`

stop CodeReady Workspaces server

```
USAGE
  $ crwctl server:stop

OPTIONS
  -h, --help                               show CLI help

  -n, --chenamespace=chenamespace          [default: workspaces] Kubernetes namespace where CodeReady Workspaces server
                                           is supposed to be deployed

  --access-token=access-token              CodeReady Workspaces OIDC Access Token

  --che-selector=che-selector              [default: app=codeready,component=codeready] Selector for CodeReady
                                           Workspaces server resources

  --deployment-name=deployment-name        [default: codeready] CodeReady Workspaces deployment name

  --listr-renderer=default|silent|verbose  [default: default] Listr renderer

  --skip-kubernetes-health-check           Skip Kubernetes health check
```

_See code: [src/commands/server/stop.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/server/stop.ts)_

## `crwctl server:update`

update CodeReady Workspaces server

```
USAGE
  $ crwctl server:update

OPTIONS
  -a, --installer=operator|olm             [default: operator] Installer type
  -h, --help                               show CLI help

  -n, --chenamespace=chenamespace          [default: workspaces] Kubernetes namespace where CodeReady Workspaces server
                                           is supposed to be deployed

  -p, --platform=openshift|crc             [default: openshift] Type of OpenShift platform. Valid values are
                                           "openshift", "crc (for CodeReady Containers)".

  -t, --templates=templates                [default: templates] Path to the templates folder

  --che-operator-image=che-operator-image  [default: registry.redhat.io/codeready-workspaces/crw-2-rhel8-operator:2.2]
                                           Container image of the operator. This parameter is used only when the
                                           installer is the operator

  --deployment-name=deployment-name        [default: codeready] CodeReady Workspaces deployment name

  --listr-renderer=default|silent|verbose  [default: default] Listr renderer

  --skip-kubernetes-health-check           Skip Kubernetes health check

  --skip-version-check                     Skip user confirmation on version check
```

_See code: [src/commands/server/update.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/server/update.ts)_

## `crwctl update`

instructions for updating crwctl

```
USAGE
  $ crwctl update
```

_See code: [src/commands/update.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/update.ts)_

## `crwctl workspace:create`

Creates a workspace from a devfile

```
USAGE
  $ crwctl workspace:create

OPTIONS
  -d, --debug                      Debug workspace start. It is useful when workspace start fails and it is needed to
                                   print more logs on startup. This flag is used in conjunction with --start flag.

  -f, --devfile=devfile            Path or URL to a valid devfile

  -h, --help                       show CLI help

  -n, --chenamespace=chenamespace  [default: workspaces] Kubernetes namespace where CodeReady Workspaces server is
                                   supposed to be deployed

  -s, --start                      Starts the workspace after creation

  --access-token=access-token      CodeReady Workspaces OIDC Access Token

  --name=name                      Workspace name: overrides the workspace name to use instead of the one defined in the
                                   devfile.

  --skip-kubernetes-health-check   Skip Kubernetes health check
```

_See code: [src/commands/workspace/create.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/workspace/create.ts)_

## `crwctl workspace:delete WORKSPACE`

delete a user's workspace

```
USAGE
  $ crwctl workspace:delete WORKSPACE

ARGUMENTS
  WORKSPACE  The workspace id to delete

OPTIONS
  -h, --help                       show CLI help

  -n, --chenamespace=chenamespace  [default: workspaces] Kubernetes namespace where CodeReady Workspaces server is
                                   supposed to be deployed

  --access-token=access-token      CodeReady Workspaces OIDC Access Token

  --delete-namespace               Indicates that a Kubernetes namespace where workspace was created will be deleted as
                                   well

  --skip-kubernetes-health-check   Skip Kubernetes health check
```

_See code: [src/commands/workspace/delete.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/workspace/delete.ts)_

## `crwctl workspace:inject`

inject configurations and tokens in a workspace

```
USAGE
  $ crwctl workspace:inject

OPTIONS
  -c, --container=container        The container name. If not specified, configuration files will be injected in all
                                   containers of the workspace pod

  -h, --help                       show CLI help

  -k, --kubeconfig                 (required) Inject the local Kubernetes configuration

  -n, --chenamespace=chenamespace  [default: workspaces] Kubernetes namespace where CodeReady Workspaces server is
                                   supposed to be deployed

  -w, --workspace=workspace        The workspace id to inject configuration into. It can be omitted if the only one
                                   running workspace exists.
                                   Use workspace:list command to get all workspaces and their
                                   statuses.

  --access-token=access-token      CodeReady Workspaces OIDC Access Token

  --kube-context=kube-context      Kubeconfig context to inject

  --skip-kubernetes-health-check   Skip Kubernetes health check
```

_See code: [src/commands/workspace/inject.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/workspace/inject.ts)_

## `crwctl workspace:list`

list workspaces

```
USAGE
  $ crwctl workspace:list

OPTIONS
  -h, --help                       show CLI help

  -n, --chenamespace=chenamespace  [default: workspaces] Kubernetes namespace where CodeReady Workspaces server is
                                   supposed to be deployed

  --access-token=access-token      CodeReady Workspaces OIDC Access Token

  --skip-kubernetes-health-check   Skip Kubernetes health check
```

_See code: [src/commands/workspace/list.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/workspace/list.ts)_

## `crwctl workspace:logs`

Collect workspace(s) logs

```
USAGE
  $ crwctl workspace:logs

OPTIONS
  -d, --directory=directory                Directory to store logs into
  -h, --help                               show CLI help

  -n, --namespace=namespace                (required) The namespace where workspace is located. Can be found in
                                           workspace configuration 'attributes.infrastructureNamespace' field.

  -w, --workspace=workspace                (required) Target workspace id. Can be found in workspace configuration 'id'
                                           field.

  --listr-renderer=default|silent|verbose  [default: default] Listr renderer

  --skip-kubernetes-health-check           Skip Kubernetes health check
```

_See code: [src/commands/workspace/logs.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/workspace/logs.ts)_

## `crwctl workspace:start WORKSPACE`

Starts a workspace

```
USAGE
  $ crwctl workspace:start WORKSPACE

ARGUMENTS
  WORKSPACE  The workspace id to start

OPTIONS
  -d, --debug                      Debug workspace start. It is useful when workspace start fails and it is needed to
                                   print more logs on startup.

  -h, --help                       show CLI help

  -n, --chenamespace=chenamespace  [default: workspaces] Kubernetes namespace where CodeReady Workspaces server is
                                   supposed to be deployed

  --access-token=access-token      CodeReady Workspaces OIDC Access Token

  --skip-kubernetes-health-check   Skip Kubernetes health check
```

_See code: [src/commands/workspace/start.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/workspace/start.ts)_

## `crwctl workspace:stop WORKSPACE`

Stop a running workspace

```
USAGE
  $ crwctl workspace:stop WORKSPACE

ARGUMENTS
  WORKSPACE  The workspace id to stop

OPTIONS
  -h, --help                       show CLI help

  -n, --chenamespace=chenamespace  [default: workspaces] Kubernetes namespace where CodeReady Workspaces server is
                                   supposed to be deployed

  --access-token=access-token      CodeReady Workspaces OIDC Access Token

  --skip-kubernetes-health-check   Skip Kubernetes health check
```

_See code: [src/commands/workspace/stop.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.2.0-RC0-redhat/src/commands/workspace/stop.ts)_
<!-- commandsstop -->

# Contributing

Contributing to crwctl is covered in [CONTRIBUTING.md](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/master/CONTRIBUTING.md)
