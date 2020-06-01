/*********************************************************************
 * Copyright (c) 2019 Red Hat, Inc.
 *
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/
import { boolean, string } from '@oclif/parser/lib/flags'

export const cheNamespace = string({
  char: 'n',
  description: 'Kubernetes namespace where CodeReady Workspaces server is supposed to be deployed',
  default: 'workspaces',
  env: 'CHE_NAMESPACE'
})

export const cheDeployment = string({
  description: 'CodeReady Workspaces deployment name',
  default: 'codeready',
  env: 'CHE_DEPLOYMENT'
})

export const listrRenderer = string({
  description: 'Listr renderer',
  options: ['default', 'silent', 'verbose'],
  default: 'default'
})

export const accessToken = string({
  description: 'CodeReady Workspaces OIDC Access Token',
  env: 'CHE_ACCESS_TOKEN'
})

export const skipKubeHealthzCheck = boolean({
  description: 'Skip Kubernetes health check',
  default: false
})
