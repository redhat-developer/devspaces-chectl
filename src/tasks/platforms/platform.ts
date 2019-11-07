/*********************************************************************
 * Copyright (c) 2019 Red Hat, Inc.
 *
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/
import Command from '@oclif/command'
import * as Listr from 'listr'

import { CRCHelper } from './crc'
import { OpenshiftTasks } from './openshift'

export class PlatformTasks {
  preflightCheckTasks(flags: any, command: Command): ReadonlyArray<Listr.ListrTask> {
    const openshiftTasks = new OpenshiftTasks()
    const crc = new CRCHelper()

    let task: Listr.ListrTask
    if (!flags.platform) {
      task = {
        title: '✈️  Platform preflight checklist',
        task: () => { command.error('Platform is required ¯\\_(ツ)_/¯') }
      }
    } else if (flags.platform === 'openshift') {
      task = {
        title: '✈️  Openshift preflight checklist',
        task: () => openshiftTasks.startTasks(flags, command)
      }
    } else if (flags.platform === 'crc') {
      task = {
        title: '✈️  CodeReady Containers preflight checklist',
        task: () => crc.startTasks(flags, command)
      }
    } else {
      task = {
        title: '✈️  Platform preflight checklist',
        task: () => { command.error(`Platform ${flags.platform} is not supported yet ¯\\_(ツ)_/¯`) }
      }
    }

    return [task]
  }
}
