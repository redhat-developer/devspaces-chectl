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
import { string } from '@oclif/parser/lib/flags'
import * as Listr from 'listr'
import * as notifier from 'node-notifier'
import * as os from 'os'
import * as path from 'path'

import { cheDeployment, cheNamespace, listrRenderer } from '../../common-flags'
import { CheTasks } from '../../tasks/che'
import { OpenshiftTasks } from '../../tasks/platforms/openshift'

export default class Logs extends Command {
  static description = 'Collect CodeReady Workspaces logs'

  static flags = {
    help: flags.help({ char: 'h' }),
    chenamespace: cheNamespace,
    'listr-renderer': listrRenderer,
    'deployment-name': cheDeployment,
    directory: string({
      char: 'd',
      description: 'Directory to store logs into'
    })
  }

  async run() {
    const { flags } = this.parse(Logs)
    const ctx: any = {}
    ctx.directory = path.resolve(flags.directory ? flags.directory : path.resolve(os.tmpdir(), 'crwctl-logs', Date.now().toString()))
    const cheTasks = new CheTasks(flags)
    const openshiftTasks = new OpenshiftTasks()
    const tasks = new Listr([], { renderer: flags['listr-renderer'] as any })

    tasks.add(openshiftTasks.testApiTasks(flags, this))
    tasks.add(cheTasks.verifyCheNamespaceExistsTask(flags, this))
    tasks.add(cheTasks.serverLogsTasks(flags, false))

    try {
      await tasks.run(ctx)
      this.log('Command server:logs has completed successfully.')
    } catch (error) {
      this.error(error)
    } finally {
      this.log(`CodeReady Workspaces logs will be available in '${ctx.directory}'`)
    }

    notifier.notify({
      title: 'crwctl',
      message: 'Command server:logs has completed successfully.'
    })

    this.exit(0)
  }
}
