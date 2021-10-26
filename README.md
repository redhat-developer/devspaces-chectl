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
* [`crwctl auth:delete CHE-API-ENDPOINT`](#crwctl-authdelete-che-api-endpoint)
* [`crwctl auth:get`](#crwctl-authget)
* [`crwctl auth:list`](#crwctl-authlist)
* [`crwctl auth:login [CHE-API-ENDPOINT]`](#crwctl-authlogin-che-api-endpoint)
* [`crwctl auth:logout`](#crwctl-authlogout)
* [`crwctl auth:use [CHE-API-ENDPOINT]`](#crwctl-authuse-che-api-endpoint)
* [`crwctl autocomplete [SHELL]`](#crwctl-autocomplete-shell)
* [`crwctl cacert:export`](#crwctl-cacertexport)
* [`crwctl dashboard:open`](#crwctl-dashboardopen)
* [`crwctl devfile:generate`](#crwctl-devfilegenerate)
* [`crwctl help [COMMAND]`](#crwctl-help-command)
* [`crwctl server:backup`](#crwctl-serverbackup)
* [`crwctl server:debug`](#crwctl-serverdebug)
* [`crwctl server:delete`](#crwctl-serverdelete)
* [`crwctl server:deploy`](#crwctl-serverdeploy)
* [`crwctl server:logs`](#crwctl-serverlogs)
* [`crwctl server:restore`](#crwctl-serverrestore)
* [`crwctl server:start`](#crwctl-serverstart)
* [`crwctl server:status`](#crwctl-serverstatus)
* [`crwctl server:stop`](#crwctl-serverstop)
* [`crwctl server:update`](#crwctl-serverupdate)
* [`crwctl update [CHANNEL]`](#crwctl-update-channel)
* [`crwctl workspace:create`](#crwctl-workspacecreate)
* [`crwctl workspace:delete WORKSPACE`](#crwctl-workspacedelete-workspace)
* [`crwctl workspace:inject`](#crwctl-workspaceinject)
* [`crwctl workspace:list`](#crwctl-workspacelist)
* [`crwctl workspace:logs`](#crwctl-workspacelogs)
* [`crwctl workspace:start WORKSPACE`](#crwctl-workspacestart-workspace)
* [`crwctl workspace:stop WORKSPACE`](#crwctl-workspacestop-workspace)

## `crwctl auth:delete CHE-API-ENDPOINT`

Delete specified login session(s)

```
USAGE
  $ crwctl auth:delete CHE-API-ENDPOINT

ARGUMENTS
  CHE-API-ENDPOINT  CodeReady Workspaces server API endpoint

OPTIONS
  -h, --help               show CLI help
  -u, --username=username  CodeReady Workspaces username
  --telemetry=on|off       Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry

EXAMPLES
  # Delete login session of the specified user on the cluster:
  crwctl auth:delete che-che.apps-crc.testing/api -u username


  # Delete all login sessions on the cluster:
  crwctl auth:delete che-che.apps-crc.testing
```

_See code: [src/commands/auth/delete.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/auth/delete.ts)_

## `crwctl auth:get`

Display active login session

```
USAGE
  $ crwctl auth:get

OPTIONS
  -h, --help          show CLI help
  --telemetry=on|off  Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/auth/get.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/auth/get.ts)_

## `crwctl auth:list`

Show all existing login sessions

```
USAGE
  $ crwctl auth:list

OPTIONS
  -h, --help          show CLI help
  --telemetry=on|off  Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/auth/list.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/auth/list.ts)_

## `crwctl auth:login [CHE-API-ENDPOINT]`

Log in to CodeReady Workspaces server

```
USAGE
  $ crwctl auth:login [CHE-API-ENDPOINT]

ARGUMENTS
  CHE-API-ENDPOINT  CodeReady Workspaces server API endpoint

OPTIONS
  -h, --help                         show CLI help
  -n, --chenamespace=chenamespace    CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'
  -p, --password=password            CodeReady Workspaces user password
  -t, --refresh-token=refresh-token  Keycloak refresh token
  -u, --username=username            CodeReady Workspaces username
  --telemetry=on|off                 Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry

EXAMPLES
  # Log in with username and password (when OpenShift OAuth is not enabled):
  crwctl auth:login https://che-che.apps-crc.testing/api -u username -p password


  # Log in with username and password (password will be asked interactively):
  crwctl auth:login che-che.apps-crc.testing -u username


  # Log in with token (when OpenShift OAuth is enabled):
  crwctl auth:login che.openshift.io -t token


  # Log in with oc token (when logged into an OpenShift cluster with oc and OpenShift OAuth is enabled):
  crwctl auth:login che.my.server.net
```

_See code: [src/commands/auth/login.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/auth/login.ts)_

## `crwctl auth:logout`

Log out of the active login session

```
USAGE
  $ crwctl auth:logout

OPTIONS
  -h, --help          show CLI help
  --telemetry=on|off  Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/auth/logout.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/auth/logout.ts)_

## `crwctl auth:use [CHE-API-ENDPOINT]`

Set active login session

```
USAGE
  $ crwctl auth:use [CHE-API-ENDPOINT]

ARGUMENTS
  CHE-API-ENDPOINT  CodeReady Workspaces server API endpoint

OPTIONS
  -h, --help               show CLI help
  -i, --interactive        Select an active login session in interactive mode
  -u, --username=username  CodeReady Workspaces username
  --telemetry=on|off       Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry

EXAMPLES
  # Set an active login session for the specified user on the given cluster:
  crwctl auth:use che-che.apps-crc.testing/api -u username


  # Switch to another user on the same cluster:
  crwctl auth:use -u another-user-on-this-server


  # Switch to the only user on the given cluster:
  crwctl auth:use my.cluster.net


  # Select an active login session in interactive mode:
  crwctl auth:use -i
```

_See code: [src/commands/auth/use.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/auth/use.ts)_

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

_See code: [@oclif/plugin-autocomplete](https://github.com/oclif/plugin-autocomplete/blob/v0.3.0/src/commands/autocomplete/index.ts)_

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
                           If this option is omitted, then Che certificate will be stored in a user's temporary directory 
      as cheCA.crt.

  -h, --help
      show CLI help

  -n, --chenamespace=chenamespace
      CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/cacert/export.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/cacert/export.ts)_

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

_See code: [src/commands/dashboard/open.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/dashboard/open.ts)_

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

  --telemetry=on|off         Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/devfile/generate.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/devfile/generate.ts)_

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

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v3.2.3/src/commands/help.ts)_

## `crwctl server:backup`

Backup CodeReady Workspaces installation

```
USAGE
  $ crwctl server:backup

OPTIONS
  -h, --help                                             show CLI help

  -n, --chenamespace=chenamespace                        CodeReady Workspaces Openshift Project. Default to
                                                         'openshift-workspaces'

  -p, --repository-password=repository-password          Password that is used to encrypt / decrypt backup repository
                                                         content

  -r, --repository-url=repository-url                    Full address of backup repository. Format is identical to
                                                         restic.

  --aws-access-key-id=aws-access-key-id                  AWS access key ID

  --aws-secret-access-key=aws-secret-access-key          AWS secret access key

  --backup-server-config-name=backup-server-config-name  Name of custom resource with backup server config

  --batch                                                Batch mode. Running a command without end user interaction.

  --password=password                                    Authentication password for backup REST server

  --ssh-key=ssh-key                                      Private SSH key for authentication on SFTP server

  --ssh-key-file=ssh-key-file                            Path to file with private SSH key for authentication on SFTP
                                                         server

  --telemetry=on|off                                     Enable or disable telemetry. This flag skips a prompt and
                                                         enable/disable telemetry

  --username=username                                    Username for authentication in backup REST server

EXAMPLES
  # Reuse existing backup configuration or create and use internal backup server if none exists:
  crwctl server:backup
  # Create and use configuration for REST backup server:
  crwctl server:backup -r rest:http://my-sert-server.net:4000/che-backup -p repopassword
  # Create and use configuration for AWS S3 (and API compatible) backup server (bucket should be precreated):
  crwctl server:backup -r s3:s3.amazonaws.com/bucketche -p repopassword
  # Create and use configuration for SFTP backup server:
  crwctl server:backup -r sftp:user@my-server.net:/srv/sftp/che-data -p repopassword
```

_See code: [src/commands/server/backup.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/server/backup.ts)_

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

_See code: [src/commands/server/debug.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/server/debug.ts)_

## `crwctl server:delete`

delete any CodeReady Workspaces related resource

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

_See code: [src/commands/server/delete.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/server/delete.ts)_

## `crwctl server:deploy`

Deploy CodeReady Workspaces server

```
USAGE
  $ crwctl server:deploy

OPTIONS
  -a, --installer=helm|operator|olm
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
                           With this strategy will be provided auto-update CodeReady Workspaces without any human 
      interaction.
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

  --helm-patch-yaml=helm-patch-yaml
      Path to yaml file with Helm Chart values patch.
                           The file format is identical to values.yaml from the chart.
                           Note, Provided command line arguments take precedence over patch file.

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

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry

  --workspace-engine=che-server|dev-workspace
      [default: che-server] Workspace Engine. If not set, default is "che-server". "dev-workspace" is experimental.

  --workspace-pvc-storage-class-name=workspace-pvc-storage-class-name
      persistent volume(s) storage class name to use to store CodeReady Workspaces workspaces data
```

_See code: [src/commands/server/deploy.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/server/deploy.ts)_

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

_See code: [src/commands/server/logs.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/server/logs.ts)_

## `crwctl server:restore`

Restore CodeReady Workspaces installation

```
USAGE
  $ crwctl server:restore

OPTIONS
  -h, --help                                             show CLI help

  -n, --chenamespace=chenamespace                        CodeReady Workspaces Openshift Project. Default to
                                                         'openshift-workspaces'

  -p, --repository-password=repository-password          Password that is used to encrypt / decrypt backup repository
                                                         content

  -r, --repository-url=repository-url                    Full address of backup repository. Format is identical to
                                                         restic.

  -s, --snapshot-id=snapshot-id                          snapshot identificator to restore from. Value "latest" means
                                                         restoring from the most recent snapshot.

  -v, --version=version                                  Che Operator version to restore to (e.g. 7.35.1). If the flag
                                                         is not set, restore to the current version.

  --aws-access-key-id=aws-access-key-id                  AWS access key ID

  --aws-secret-access-key=aws-secret-access-key          AWS secret access key

  --backup-cr-name=backup-cr-name                        Name of a backup custom resource to restore from

  --backup-server-config-name=backup-server-config-name  Name of custom resource with backup server config

  --batch                                                Batch mode. Running a command without end user interaction.

  --password=password                                    Authentication password for backup REST server

  --rollback                                             Rolling back to previous version of CodeReady Workspaces only
                                                         if backup exists

  --ssh-key=ssh-key                                      Private SSH key for authentication on SFTP server

  --ssh-key-file=ssh-key-file                            Path to file with private SSH key for authentication on SFTP
                                                         server

  --telemetry=on|off                                     Enable or disable telemetry. This flag skips a prompt and
                                                         enable/disable telemetry

  --username=username                                    Username for authentication in backup REST server

EXAMPLES
  # Restore from the latest snapshot from a provided REST backup server:
  crwctl server:restore -r rest:http://my-sert-server.net:4000/che-backup -p repopassword --snapshot-id=latest
  # Restore from the latest snapshot from a provided AWS S3 (or API compatible) backup server (bucket must be 
  precreated):
  crwctl server:restore -r s3:s3.amazonaws.com/bucketche -p repopassword --snapshot-id=latest
  # Restore from the latest snapshot from a provided SFTP backup server:
  crwctl server:restore -r sftp:user@my-server.net:/srv/sftp/che-data -p repopassword --snapshot-id=latest
  # Restore from a specific snapshot to a given CodeReady Workspaces version from a provided REST backup server:
  crwctl server:restore -r rest:http://my-sert-server.net:4000/che-backup -p repopassword --version=7.35.2 
  --snapshot-id=9ea02f58
  # Rollback to a previous version only if backup exists:
  crwctl server:restore --rollback
  # Restore from a specific backup object:
  crwctl server:restore --backup-cr-name=backup-object-name
```

_See code: [src/commands/server/restore.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/server/restore.ts)_

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

_See code: [src/commands/server/start.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/server/start.ts)_

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

_See code: [src/commands/server/status.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/server/status.ts)_

## `crwctl server:stop`

stop CodeReady Workspaces server

```
USAGE
  $ crwctl server:stop

OPTIONS
  -h, --help
      show CLI help

  -n, --chenamespace=chenamespace
      CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  --access-token=access-token
      CodeReady Workspaces OIDC Access Token. See the documentation how to obtain token: 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-keycloak_
      authenticating-to-the-che-server and 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-openshift
      -token-through-keycloak_authenticating-to-the-che-server.

  --che-selector=che-selector
      [default: app=codeready,component=codeready] Selector for CodeReady Workspaces server resources

  --deployment-name=deployment-name
      [default: codeready] CodeReady Workspaces deployment name

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/server/stop.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/server/stop.ts)_

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

_See code: [src/commands/server/update.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/server/update.ts)_

## `crwctl update [CHANNEL]`

update the crwctl CLI

```
USAGE
  $ crwctl update [CHANNEL]

OPTIONS
  --from-local  interactively choose an already installed version
```

_See code: [@oclif/plugin-update](https://github.com/oclif/plugin-update/blob/v1.5.0/src/commands/update.ts)_

## `crwctl workspace:create`

Creates a workspace from a devfile

```
USAGE
  $ crwctl workspace:create

OPTIONS
  -d, --debug
      Debug workspace start. It is useful when workspace start fails and it is needed to print more logs on startup. This 
      flag is used in conjunction with --start flag.

  -f, --devfile=devfile
      Path or URL to a valid devfile

  -h, --help
      show CLI help

  -n, --chenamespace=chenamespace
      CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  -s, --start
      Starts the workspace after creation

  --access-token=access-token
      CodeReady Workspaces OIDC Access Token. See the documentation how to obtain token: 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-keycloak_
      authenticating-to-the-che-server and 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-openshift
      -token-through-keycloak_authenticating-to-the-che-server.

  --che-api-endpoint=che-api-endpoint
      CodeReady Workspaces server API endpoint

  --name=name
      Workspace name: overrides the workspace name to use instead of the one defined in the devfile.

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/workspace/create.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/workspace/create.ts)_

## `crwctl workspace:delete WORKSPACE`

Delete a stopped workspace - use workspace:stop to stop the workspace before deleting it

```
USAGE
  $ crwctl workspace:delete WORKSPACE

ARGUMENTS
  WORKSPACE  The workspace id to delete

OPTIONS
  -h, --help
      show CLI help

  -n, --chenamespace=chenamespace
      CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  --access-token=access-token
      CodeReady Workspaces OIDC Access Token. See the documentation how to obtain token: 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-keycloak_
      authenticating-to-the-che-server and 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-openshift
      -token-through-keycloak_authenticating-to-the-che-server.

  --che-api-endpoint=che-api-endpoint
      CodeReady Workspaces server API endpoint

  --delete-namespace
      Indicates that a Kubernetes namespace where workspace was created will be deleted as well

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/workspace/delete.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/workspace/delete.ts)_

## `crwctl workspace:inject`

Inject configurations and tokens in a workspace

```
USAGE
  $ crwctl workspace:inject

OPTIONS
  -c, --container=container
      The container name. If not specified, configuration files will be injected in all containers of the workspace pod

  -h, --help
      show CLI help

  -k, --kubeconfig
      (required) Inject the local Kubernetes configuration

  -n, --chenamespace=chenamespace
      CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  -w, --workspace=workspace
      The workspace id to inject configuration into. It can be omitted if the only one running workspace exists.
                           Use workspace:list command to get all workspaces and their statuses.

  --access-token=access-token
      CodeReady Workspaces OIDC Access Token. See the documentation how to obtain token: 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-keycloak_
      authenticating-to-the-che-server and 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-openshift
      -token-through-keycloak_authenticating-to-the-che-server.

  --che-api-endpoint=che-api-endpoint
      CodeReady Workspaces server API endpoint

  --kube-context=kube-context
      Kubeconfig context to inject

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/workspace/inject.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/workspace/inject.ts)_

## `crwctl workspace:list`

List workspaces

```
USAGE
  $ crwctl workspace:list

OPTIONS
  -h, --help
      show CLI help

  -n, --chenamespace=chenamespace
      CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  --access-token=access-token
      CodeReady Workspaces OIDC Access Token. See the documentation how to obtain token: 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-keycloak_
      authenticating-to-the-che-server and 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-openshift
      -token-through-keycloak_authenticating-to-the-che-server.

  --che-api-endpoint=che-api-endpoint
      CodeReady Workspaces server API endpoint

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/workspace/list.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/workspace/list.ts)_

## `crwctl workspace:logs`

Collect workspace(s) logs

```
USAGE
  $ crwctl workspace:logs

OPTIONS
  -d, --directory=directory       Directory to store logs into
  -h, --help                      show CLI help

  -n, --namespace=namespace       (required) The namespace where workspace is located. Can be found in workspace
                                  configuration 'attributes.infrastructureNamespace' field.

  -w, --workspace=workspace       (required) Target workspace id. Can be found in workspace configuration 'id' field.

  --follow                        Indicate if logs should be streamed

  --skip-kubernetes-health-check  Skip Kubernetes health check

  --telemetry=on|off              Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/workspace/logs.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/workspace/logs.ts)_

## `crwctl workspace:start WORKSPACE`

Starts a workspace

```
USAGE
  $ crwctl workspace:start WORKSPACE

ARGUMENTS
  WORKSPACE  The workspace id to start

OPTIONS
  -d, --debug
      Debug workspace start. It is useful when workspace start fails and it is needed to print more logs on startup.

  -h, --help
      show CLI help

  -n, --chenamespace=chenamespace
      CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  --access-token=access-token
      CodeReady Workspaces OIDC Access Token. See the documentation how to obtain token: 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-keycloak_
      authenticating-to-the-che-server and 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-openshift
      -token-through-keycloak_authenticating-to-the-che-server.

  --che-api-endpoint=che-api-endpoint
      CodeReady Workspaces server API endpoint

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/workspace/start.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/workspace/start.ts)_

## `crwctl workspace:stop WORKSPACE`

Stop a running workspace

```
USAGE
  $ crwctl workspace:stop WORKSPACE

ARGUMENTS
  WORKSPACE  The workspace id to stop

OPTIONS
  -h, --help
      show CLI help

  -n, --chenamespace=chenamespace
      CodeReady Workspaces Openshift Project. Default to 'openshift-workspaces'

  --access-token=access-token
      CodeReady Workspaces OIDC Access Token. See the documentation how to obtain token: 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-keycloak_
      authenticating-to-the-che-server and 
      https://www.eclipse.org/che/docs/che-7/administration-guide/authenticating-users/#obtaining-the-token-from-openshift
      -token-through-keycloak_authenticating-to-the-che-server.

  --che-api-endpoint=che-api-endpoint
      CodeReady Workspaces server API endpoint

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --telemetry=on|off
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
```

_See code: [src/commands/workspace/stop.ts](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/v2.13.0-20211026-1455-redhat/src/commands/workspace/stop.ts)_
<!-- commandsstop -->

# Contributing

Contributing to crwctl is covered in [CONTRIBUTING.md](https://github.com/redhat-developer/codeready-workspaces-chectl/blob/master/CONTRIBUTING.md)
