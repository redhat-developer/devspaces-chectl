/*********************************************************************
 * Copyright (c) 2019 Red Hat, Inc.
 *
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/

import { Command, flags } from '@oclif/command'
import * as Listrq from 'listr'

import { cheNamespace, listrRenderer } from '../../common-flags'
import { CheTasks } from '../../tasks/che'
import { OperatorTasks } from '../../tasks/installers/operator'
import { OpenshiftTasks } from '../../tasks/platforms/openshift'

export default class Delete extends Command {
  static description = 'delete any Che related resource: Kubernetes/OpenShift/Helm'

  static flags = {
    help: flags.help({ char: 'h' }),
    chenamespace: cheNamespace,
    'listr-renderer': listrRenderer
  }

  async run() {
    const { flags } = this.parse(Delete)

    const notifier = require('node-notifier')

    const openshiftTasks = new OpenshiftTasks()
    const operatorTasks = new OperatorTasks()
    const cheTasks = new CheTasks(flags)

    let tasks = new Listrq(undefined,
      { renderer: flags['listr-renderer'] as any }
    )

    tasks.add(openshiftTasks.testApiTasks(flags, this))
    tasks.add(operatorTasks.deleteTasks(flags))
    tasks.add(cheTasks.deleteTasks(flags))

    await tasks.run()

    notifier.notify({
      title: 'chectl',
      message: 'Command server:update has completed.'
    })

    this.exit(0)
  }
}
