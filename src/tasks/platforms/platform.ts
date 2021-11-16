/**
 * Copyright (c) 2019-2021 Red Hat, Inc.
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *   Red Hat, Inc. - initial API and implementation
 */

import Command from '@oclif/command'
import { cli } from 'cli-ux'
import * as Listr from 'listr'
import { CRCHelper } from './crc'
import { OpenshiftTasks } from './openshift'

/**
 * Platform specific tasks.
 */
export class PlatformTasks {
  protected openshiftTasks: OpenshiftTasks
  protected crc: CRCHelper

  constructor(flags: any) {
    this.openshiftTasks = new OpenshiftTasks()
    this.crc = new CRCHelper()
  }

  preflightCheckTasks(flags: any, command: Command): ReadonlyArray<Listr.ListrTask> {
    let task: Listr.ListrTask
    if (!flags.platform) {
      task = {
        title: '✈️  Platform preflight checklist',
        task: () => {
          command.error('Platform is required ¯\\_(ツ)_/¯')
        },
      }
    } else if (flags.platform === 'openshift') {
      task = {
        title: '✈️  Openshift preflight checklist',
        task: () => this.openshiftTasks.preflightCheckTasks(flags, command),
      }
    } else if (flags.platform === 'crc') {
      task = {
        title: '✈️  CodeReady Containers preflight checklist',
        task: () => this.crc.preflightCheckTasks(flags, command),
      }
    } else {
      task = {
        title: '✈️  Platform preflight checklist',
        task: () => {
          command.error(`Platform ${flags.platform} is not supported yet ¯\\_(ツ)_/¯`)
        },
      }
    }

    return [task]
  }

  configureApiServerForDex(flags: any): ReadonlyArray<Listr.ListrTask> {
    if (flags.platform === 'minikube') {
      return []
    } else {
      cli.error(`It is not possible to configure API server for ${flags.platform}.`)
    }
  }
}
