dsc
======

The [Red Hat OpenShift Dev Spaces](https://developers.redhat.com/products/openshift-dev-spaces/overview) CLI for OpenShift is `dsc`.

For OpenShift 4, can also use the OperatorHub installation method:

https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.6/html-single/administration_guide/index#installing-devspaces

[![oclif](https://img.shields.io/badge/cli-oclif-brightgreen.svg)](https://oclif.io)

## Report issues

[Issues are tracked in JIRA](https://issues.jboss.org/browse/CRW-463?jql=project%20%3D%20CRW%20AND%20(component%20%3D%20dsc%20OR%20labels%20%3D%20dsc)).

## Table Of Contents

<!-- toc -->
* [Installation](#installation)
* [1. get install script](#1-get-install-script)
* [2. install to $HOME/dsc/ from :next tag](#2-install-to-homedsc-from-next-tag)
* [3. add dsc to your PATH](#3-add-dsc-to-your-path)
* [Usage](#usage)
* [Commands](#commands)
* [Contributing](#contributing)
<!-- tocstop -->
# Installation

Container images with multiple arches of dsc builds are available at [quay.io/devspaces/dsc:next](https://quay.io/devspaces/dsc:next).

For the current list of supported arches, see [build/scripts/build.sh](https://github.com/redhat-developer/devspaces-chectl/blob/devspaces-3-rhel-8/build/scripts/build.sh#L23).

To install as `$HOME/dsc/bin/dsc`:

```sh-session
# 1. get install script
cd /tmp; curl -sSLO https://raw.githubusercontent.com/redhat-developer/devspaces-chectl/devspaces-3-rhel-8/build/scripts/installDscFromContainer.sh; chmod +x installDscFromContainer.sh

# 2. install to $HOME/dsc/ from :next tag
./installDscFromContainer.sh quay.io/devspaces/dsc:next -t $HOME --verbose

# 3. add dsc to your PATH
export PATH=${PATH%":$HOME/dsc/bin"}:$HOME/dsc/bin
```


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
* [`dsc commands`](#dsc-commands)
* [`dsc dashboard:open`](#dsc-dashboardopen)
* [`dsc help [COMMANDS]`](#dsc-help-commands)
* [`dsc server:debug`](#dsc-serverdebug)
* [`dsc server:delete`](#dsc-serverdelete)
* [`dsc server:deploy`](#dsc-serverdeploy)
* [`dsc server:logs`](#dsc-serverlogs)
* [`dsc server:start`](#dsc-serverstart)
* [`dsc server:status`](#dsc-serverstatus)
* [`dsc server:stop`](#dsc-serverstop)
* [`dsc server:update`](#dsc-serverupdate)
* [`dsc update [CHANNEL]`](#dsc-update-channel)
* [`dsc version`](#dsc-version)

## `dsc autocomplete [SHELL]`

display autocomplete installation instructions

```
USAGE
  $ dsc autocomplete [SHELL] [-r]

ARGUMENTS
  SHELL  (zsh|bash|powershell) Shell type

FLAGS
  -r, --refresh-cache  Refresh cache (ignores displaying instructions)

DESCRIPTION
  display autocomplete installation instructions

EXAMPLES
  $ dsc autocomplete

  $ dsc autocomplete bash

  $ dsc autocomplete zsh

  $ dsc autocomplete powershell

  $ dsc autocomplete --refresh-cache
```

_See code: [@oclif/plugin-autocomplete](https://github.com/oclif/plugin-autocomplete/blob/v2.3.9/src/commands/autocomplete/index.ts)_

## `dsc cacert:export`

Retrieves Red Hat OpenShift Dev Spaces self-signed certificate

```
USAGE
  $ dsc cacert:export [-h] [-n <value>] [--telemetry on|off] [-d <value>]

FLAGS
  -d, --destination=<value>
      Destination where to store Red Hat OpenShift Dev Spaces self-signed CA certificate.
      If the destination is a file (might not exist), then the certificate will be saved there in PEM format.
      If the destination is a directory, then cheCA.crt file will be created there with Red Hat OpenShift Dev Spaces
      certificate in PEM format.
      If this option is omitted, then Red Hat OpenShift Dev Spaces certificate will be stored in a user's temporary
      directory as cheCA.crt.

  -h, --help
      Show CLI help.

  -n, --chenamespace=<value>
      Red Hat OpenShift Dev Spaces Openshift Project.

  --telemetry=<option>
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
      <options: on|off>

DESCRIPTION
  Retrieves Red Hat OpenShift Dev Spaces self-signed certificate
```

_See code: [src/commands/cacert/export.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.12.0-CI/src/commands/cacert/export.ts)_

## `dsc commands`

list all the commands

```
USAGE
  $ dsc commands [--json] [-h] [--hidden] [--tree] [--columns <value> | -x] [--filter <value>] [--no-header |
    [--csv | --no-truncate]] [--output csv|json|yaml |  | ] [--sort <value>]

FLAGS
  -h, --help         Show CLI help.
  -x, --extended     show extra columns
  --columns=<value>  only show provided columns (comma-separated)
  --csv              output is csv format [alias: --output=csv]
  --filter=<value>   filter property by partial string matching, ex: name=foo
  --hidden           show hidden commands
  --no-header        hide table header from output
  --no-truncate      do not truncate output to fit screen
  --output=<option>  output in a more machine friendly format
                     <options: csv|json|yaml>
  --sort=<value>     property to sort by (prepend '-' for descending)
  --tree             show tree of commands

GLOBAL FLAGS
  --json  Format output as json.

DESCRIPTION
  list all the commands
```

_See code: [@oclif/plugin-commands](https://github.com/oclif/plugin-commands/blob/v3.0.7/src/commands/commands.ts)_

## `dsc dashboard:open`

Open Red Hat OpenShift Dev Spaces dashboard

```
USAGE
  $ dsc dashboard:open [-h] [-n <value>] [--telemetry on|off]

FLAGS
  -h, --help                  Show CLI help.
  -n, --chenamespace=<value>  Red Hat OpenShift Dev Spaces Openshift Project.
  --telemetry=<option>        Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
                              <options: on|off>

DESCRIPTION
  Open Red Hat OpenShift Dev Spaces dashboard
```

_See code: [src/commands/dashboard/open.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.12.0-CI/src/commands/dashboard/open.ts)_

## `dsc help [COMMANDS]`

Display help for dsc.

```
USAGE
  $ dsc help [COMMANDS] [-n]

ARGUMENTS
  COMMANDS  Command to show help for.

FLAGS
  -n, --nested-commands  Include all nested commands in the output.

DESCRIPTION
  Display help for dsc.
```

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v6.0.7/src/commands/help.ts)_

## `dsc server:debug`

Enable local debug of Red Hat OpenShift Dev Spaces server

```
USAGE
  $ dsc server:debug [-h] [--debug-port <value>] [-n <value>] [--telemetry on|off] [--skip-kubernetes-health-check]

FLAGS
  -h, --help                      Show CLI help.
  -n, --chenamespace=<value>      Red Hat OpenShift Dev Spaces Openshift Project.
  --debug-port=<value>            [default: 8000] Red Hat OpenShift Dev Spaces server debug port
  --skip-kubernetes-health-check  Skip Kubernetes health check
  --telemetry=<option>            Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
                                  <options: on|off>

DESCRIPTION
  Enable local debug of Red Hat OpenShift Dev Spaces server
```

_See code: [src/commands/server/debug.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.12.0-CI/src/commands/server/debug.ts)_

## `dsc server:delete`

delete any Red Hat OpenShift Dev Spaces related resource

```
USAGE
  $ dsc server:delete [-h] [-n <value>] [--delete-all] [--delete-namespace] [--telemetry on|off]
    [--skip-kubernetes-health-check] [-y | --batch]

FLAGS
  -h, --help                      Show CLI help.
  -n, --chenamespace=<value>      Red Hat OpenShift Dev Spaces Openshift Project.
  -y, --yes                       Automatic yes to prompts; assume "yes" as answer to all prompts and run
                                  non-interactively
  --batch                         Batch mode. Running a command without end user interaction.
  --delete-all                    Indicates to delete Red Hat OpenShift Dev Spaces and Dev Workspace related resources
  --delete-namespace              Indicates that a Red Hat OpenShift Dev Spaces namespace will be deleted as well
  --skip-kubernetes-health-check  Skip Kubernetes health check
  --telemetry=<option>            Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
                                  <options: on|off>

DESCRIPTION
  delete any Red Hat OpenShift Dev Spaces related resource
```

_See code: [src/commands/server/delete.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.12.0-CI/src/commands/server/delete.ts)_

## `dsc server:deploy`

Deploy Red Hat OpenShift Dev Spaces server

```
USAGE
  $ dsc server:deploy -p openshift|crc [-h] [-n <value>] [--batch] [-i <value>] [-t <value>]
    [--devfile-registry-url <value>] [--plugin-registry-url <value>] [--k8spodwaittimeout <value>] [--k8spodreadytimeout
    <value>] [--k8spoddownloadimagetimeout <value>] [--k8spoderrorrechecktimeout <value>] [-d <value>] [--debug]
    [--che-operator-image <value>] [--che-operator-cr-yaml <value>] [--che-operator-cr-patch-yaml <value>]
    [--workspace-pvc-storage-class-name <value>] [--skip-version-check] [--skip-cert-manager]
    [--skip-devworkspace-operator] [--skip-oidc-provider-check] [--auto-update] [--starting-csv <value>]
    [--package-manifest-name <value>] [--catalog-source-yaml <value> --olm-channel stable|latest|fast|next]
    [--catalog-source-name <value> --catalog-source-namespace <value> ] [--catalog-source-image <value> ]
    [--cluster-monitoring] [--telemetry on|off] [--skip-kubernetes-health-check]

FLAGS
  -d, --directory=<value>
      Directory to store logs into

  -h, --help
      Show CLI help.

  -i, --cheimage=<value>
      Red Hat OpenShift Dev Spaces server container image

  -n, --chenamespace=<value>
      Red Hat OpenShift Dev Spaces Openshift Project.

  -p, --platform=<option>
      (required) [default: openshift] Type of OpenShift platform. Valid values are "openshift", "crc (for OpenShift
      Local)".
      <options: openshift|crc>

  -t, --templates=<value>
      Path to the templates folder

  --[no-]auto-update
      Auto update approval strategy for installation Red Hat OpenShift Dev Spaces.
      With this strategy will be provided auto-update Red Hat OpenShift Dev Spaces without any human interaction.
      By default this flag is enabled.

  --batch
      Batch mode. Running a command without end user interaction.

  --catalog-source-image=<value>
      OLM catalog source image or index bundle (IIB) from which to install the Red Hat OpenShift Dev Spaces operator.

  --catalog-source-name=<value>
      Name of the OLM catalog source or index bundle (IIB) from which to install Red Hat OpenShift Dev Spaces operator.

  --catalog-source-namespace=<value>
      Namespace for OLM catalog source to install Red Hat OpenShift Dev Spaces operator.

  --catalog-source-yaml=<value>
      Path to a yaml file that describes custom catalog source for installation Red Hat OpenShift Dev Spaces operator.
      Catalog source will be applied to the namespace with Red Hat OpenShift Dev Spaces operator.
      Also you need define 'olm-channel' name and 'package-manifest-name'.

  --che-operator-cr-patch-yaml=<value>
      Path to a yaml file that overrides the default values in CheCluster CR used by the operator. This parameter is used
      only when the installer is the 'operator' or the 'olm'.

  --che-operator-cr-yaml=<value>
      Path to a yaml file that defines a CheCluster used by the operator.

  --che-operator-image=<value>
      Container image of the operator.

  --cluster-monitoring
      Enable cluster monitoring to scrape Red Hat OpenShift Dev Spaces metrics in Prometheus.
      This parameter is used only when the platform is 'openshift'.

  --debug
      'Enables the debug mode for Red Hat OpenShift Dev Spaces server. To debug Red Hat OpenShift Dev Spaces server from
      localhost use 'server:debug' command.'

  --devfile-registry-url=<value>
      The URL of the external Devfile registry.

  --k8spoddownloadimagetimeout=<value>
      [default: 1200000] Waiting time for Pod downloading image (in milliseconds)

  --k8spoderrorrechecktimeout=<value>
      [default: 60000] Waiting time for Pod rechecking error (in milliseconds)

  --k8spodreadytimeout=<value>
      [default: 60000] Waiting time for Pod Ready condition (in milliseconds)

  --k8spodwaittimeout=<value>
      [default: 60000] Waiting time for Pod scheduled condition (in milliseconds)

  --olm-channel=<option>
      [default: stable] Olm channel to install Red Hat OpenShift Dev Spaces.
      The default 'stable' value will deploy the latest supported stable version of Red Hat OpenShift Dev Spaces from the
      Red Hat Ecosystem Catalog.'
      'latest' allows to deploy the latest unreleased version from quay.io.
      'fast' or 'next' will deploy the next unreleased, unsupported, CI version of Red Hat OpenShift Dev Spaces from
      quay.io.
      <options: stable|latest|fast|next>

  --package-manifest-name=<value>
      Package manifest name to subscribe to Red Hat OpenShift Dev Spaces OLM package manifest.

  --plugin-registry-url=<value>
      The URL of the external plugin registry.

  --skip-cert-manager
      Skip installing Cert Manager (Kubernetes cluster only).

  --skip-devworkspace-operator
      Skip installing Dev Workspace Operator.

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --skip-oidc-provider-check
      Skip OIDC Provider check

  --skip-version-check
      Skip minimal versions check.

  --starting-csv=<value>
      Starting cluster service version(CSV) for installation Red Hat OpenShift Dev Spaces.
      Flags uses to set up start installation version Che.
      For example: 'starting-csv' provided with value 'eclipse-che.v7.10.0' for stable channel.
      Then OLM will install Red Hat OpenShift Dev Spaces with version 7.10.0.
      Notice: this flag will be ignored with 'auto-update' flag. OLM with auto-update mode installs the latest known
      version.

  --telemetry=<option>
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
      <options: on|off>

  --workspace-pvc-storage-class-name=<value>
      persistent volume(s) storage class name to use to store Red Hat OpenShift Dev Spaces workspaces data

DESCRIPTION
  Deploy Red Hat OpenShift Dev Spaces server
```

_See code: [src/commands/server/deploy.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.12.0-CI/src/commands/server/deploy.ts)_

## `dsc server:logs`

Collect Red Hat OpenShift Dev Spaces logs

```
USAGE
  $ dsc server:logs [-h] [-d <value>] [-n <value>] [--telemetry on|off] [--skip-kubernetes-health-check]

FLAGS
  -d, --directory=<value>         Directory to store logs into
  -h, --help                      Show CLI help.
  -n, --chenamespace=<value>      Red Hat OpenShift Dev Spaces Openshift Project.
  --skip-kubernetes-health-check  Skip Kubernetes health check
  --telemetry=<option>            Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
                                  <options: on|off>

DESCRIPTION
  Collect Red Hat OpenShift Dev Spaces logs
```

_See code: [src/commands/server/logs.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.12.0-CI/src/commands/server/logs.ts)_

## `dsc server:start`

Start Red Hat OpenShift Dev Spaces server

```
USAGE
  $ dsc server:start [-h] [-n <value>] [--telemetry on|off] [--skip-kubernetes-health-check] [--batch]
    [--k8spodwaittimeout <value>] [--k8spodreadytimeout <value>] [--k8spoddownloadimagetimeout <value>]
    [--k8spoderrorrechecktimeout <value>] [-d <value>]

FLAGS
  -d, --directory=<value>               Directory to store logs into
  -h, --help                            Show CLI help.
  -n, --chenamespace=<value>            Red Hat OpenShift Dev Spaces Openshift Project.
  --batch                               Batch mode. Running a command without end user interaction.
  --k8spoddownloadimagetimeout=<value>  [default: 1200000] Waiting time for Pod downloading image (in milliseconds)
  --k8spoderrorrechecktimeout=<value>   [default: 60000] Waiting time for Pod rechecking error (in milliseconds)
  --k8spodreadytimeout=<value>          [default: 60000] Waiting time for Pod Ready condition (in milliseconds)
  --k8spodwaittimeout=<value>           [default: 60000] Waiting time for Pod scheduled condition (in milliseconds)
  --skip-kubernetes-health-check        Skip Kubernetes health check
  --telemetry=<option>                  Enable or disable telemetry. This flag skips a prompt and enable/disable
                                        telemetry
                                        <options: on|off>

DESCRIPTION
  Start Red Hat OpenShift Dev Spaces server
```

_See code: [src/commands/server/start.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.12.0-CI/src/commands/server/start.ts)_

## `dsc server:status`

Status Red Hat OpenShift Dev Spaces server

```
USAGE
  $ dsc server:status [-h] [-n <value>] [--telemetry on|off]

FLAGS
  -h, --help                  Show CLI help.
  -n, --chenamespace=<value>  Red Hat OpenShift Dev Spaces Openshift Project.
  --telemetry=<option>        Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
                              <options: on|off>

DESCRIPTION
  Status Red Hat OpenShift Dev Spaces server
```

_See code: [src/commands/server/status.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.12.0-CI/src/commands/server/status.ts)_

## `dsc server:stop`

stop Red Hat OpenShift Dev Spaces server

```
USAGE
  $ dsc server:stop [-h] [-n <value>] [--telemetry on|off] [--skip-kubernetes-health-check]

FLAGS
  -h, --help                      Show CLI help.
  -n, --chenamespace=<value>      Red Hat OpenShift Dev Spaces Openshift Project.
  --skip-kubernetes-health-check  Skip Kubernetes health check
  --telemetry=<option>            Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
                                  <options: on|off>

DESCRIPTION
  stop Red Hat OpenShift Dev Spaces server
```

_See code: [src/commands/server/stop.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.12.0-CI/src/commands/server/stop.ts)_

## `dsc server:update`

Update Red Hat OpenShift Dev Spaces server.

```
USAGE
  $ dsc server:update [-h] [-n <value>] [-y | --batch] [-t <value>] [--che-operator-image <value>]
    [--che-operator-cr-patch-yaml <value>] [--skip-devworkspace-operator] [--skip-kubernetes-health-check]
    [--skip-version-check] [--telemetry on|off] [--package-manifest-name <value>] [--catalog-source-namespace <value>
    --catalog-source-name <value> --olm-channel stable|latest|fast|next] [--catalog-source-yaml <value> ]
    [--catalog-source-image <value> ] [--auto-update] [--starting-csv <value>]

FLAGS
  -h, --help
      Show CLI help.

  -n, --chenamespace=<value>
      Red Hat OpenShift Dev Spaces Openshift Project.

  -t, --templates=<value>
      Path to the templates folder

  -y, --yes
      Automatic yes to prompts; assume "yes" as answer to all prompts and run non-interactively

  --[no-]auto-update
      Auto update approval strategy for installation Red Hat OpenShift Dev Spaces.
      With this strategy will be provided auto-update Red Hat OpenShift Dev Spaces without any human interaction.
      By default this flag is enabled.

  --batch
      Batch mode. Running a command without end user interaction.

  --catalog-source-image=<value>
      OLM catalog source image or index bundle (IIB) from which to install the Red Hat OpenShift Dev Spaces operator.

  --catalog-source-name=<value>
      Name of the OLM catalog source or index bundle (IIB) from which to install Red Hat OpenShift Dev Spaces operator.

  --catalog-source-namespace=<value>
      Namespace for OLM catalog source to install Red Hat OpenShift Dev Spaces operator.

  --catalog-source-yaml=<value>
      Path to a yaml file that describes custom catalog source for installation Red Hat OpenShift Dev Spaces operator.
      Catalog source will be applied to the namespace with Red Hat OpenShift Dev Spaces operator.
      Also you need define 'olm-channel' name and 'package-manifest-name'.

  --che-operator-cr-patch-yaml=<value>
      Path to a yaml file that overrides the default values in CheCluster CR used by the operator. This parameter is used
      only when the installer is the 'operator' or the 'olm'.

  --che-operator-image=<value>
      Container image of the operator.

  --olm-channel=<option>
      [default: stable] Olm channel to install Red Hat OpenShift Dev Spaces.
      The default 'stable' value will deploy the latest supported stable version of Red Hat OpenShift Dev Spaces from the
      Red Hat Ecosystem Catalog.'
      'latest' allows to deploy the latest unreleased version from quay.io.
      'fast' or 'next' will deploy the next unreleased, unsupported, CI version of Red Hat OpenShift Dev Spaces from
      quay.io.
      <options: stable|latest|fast|next>

  --package-manifest-name=<value>
      Package manifest name to subscribe to Red Hat OpenShift Dev Spaces OLM package manifest.

  --skip-devworkspace-operator
      Skip installing Dev Workspace Operator.

  --skip-kubernetes-health-check
      Skip Kubernetes health check

  --skip-version-check
      Skip minimal versions check.

  --starting-csv=<value>
      Starting cluster service version(CSV) for installation Red Hat OpenShift Dev Spaces.
      Flags uses to set up start installation version Che.
      For example: 'starting-csv' provided with value 'eclipse-che.v7.10.0' for stable channel.
      Then OLM will install Red Hat OpenShift Dev Spaces with version 7.10.0.
      Notice: this flag will be ignored with 'auto-update' flag. OLM with auto-update mode installs the latest known
      version.

  --telemetry=<option>
      Enable or disable telemetry. This flag skips a prompt and enable/disable telemetry
      <options: on|off>

DESCRIPTION
  Update Red Hat OpenShift Dev Spaces server.

EXAMPLES
  # Update Red Hat OpenShift Dev Spaces:

    $ dsc server:update

  # Update Red Hat OpenShift Dev Spaces in 'eclipse-che' namespace:

    $ dsc server:update -n eclipse-che

  # Update Red Hat OpenShift Dev Spaces and update its configuration in the custom resource:

    $ dsc server:update --che-operator-cr-patch-yaml patch.yaml

  # Update Red Hat OpenShift Dev Spaces from the provided channel:

    $ dsc server:update --olm-channel next

  # Update Red Hat OpenShift Dev Spaces from the provided CatalogSource and channel:

    $ dsc server:update --olm-channel fast --catalog-source-name MyCatalogName --catalog-source-namespace \
      MyCatalogNamespace

  # Create CatalogSource based on provided image and update Red Hat OpenShift Dev Spaces from it:

    $ dsc server:update --olm-channel latest --catalog-source-image MyCatalogImage

  # Create a CatalogSource defined in yaml file and update Red Hat OpenShift Dev Spaces from it:

    $ dsc server:update --olm-channel stable --catalog-source-yaml PATH_TO_CATALOG_SOURCE_YAML
```

_See code: [src/commands/server/update.ts](https://github.com/redhat-developer/devspaces-chectl/blob/v3.12.0-CI/src/commands/server/update.ts)_

## `dsc update [CHANNEL]`

update the dsc CLI

```
USAGE
  $ dsc update [CHANNEL] [-a] [--force] [-i | -v <value>]

FLAGS
  -a, --available        See available versions.
  -i, --interactive      Interactively select version to install. This is ignored if a channel is provided.
  -v, --version=<value>  Install a specific version.
  --force                Force a re-download of the requested version.

DESCRIPTION
  update the dsc CLI

EXAMPLES
  Update to the stable channel:

    $ dsc update stable

  Update to a specific version:

    $ dsc update --version 1.0.0

  Interactively select version:

    $ dsc update --interactive

  See available versions:

    $ dsc update --available
```

_See code: [@oclif/plugin-update](https://github.com/oclif/plugin-update/blob/v4.1.4/dist/commands/update.ts)_

## `dsc version`

```
USAGE
  $ dsc version [--json] [--verbose]

FLAGS
  --verbose  Show additional information about the CLI.

GLOBAL FLAGS
  --json  Format output as json.

FLAG DESCRIPTIONS
  --verbose  Show additional information about the CLI.

    Additionally shows the architecture, node version, operating system, and versions of plugins that the CLI is using.
```

_See code: [@oclif/plugin-version](https://github.com/oclif/plugin-version/blob/v2.0.1/src/commands/version.ts)_
<!-- commandsstop -->

# Contributing

Contributing to dsc is covered in [CONTRIBUTING.md](https://github.com/redhat-developer/devspaces-chectl/blob/master/CONTRIBUTING.md)
