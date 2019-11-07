/*********************************************************************
 * Copyright (c) 2019 Red Hat, Inc.
 *
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/

import { Command } from '@oclif/command'
import * as commandExists from 'command-exists'
import * as execa from 'execa'
import * as Listr from 'listr'

import { KubeHelper } from '../../api/kube'

export class OpenshiftTasks {
  /**
   * Returns tasks which tests if K8s or OpenShift API is configured in the current context.
   *
   * `isOpenShift` property is provisioned into context.
   */
  testApiTasks(flags: any, command: Command): Listr.ListrTask {
    let kube = new KubeHelper(flags)
    return {
      title: 'Verify OpenShift API',
      task: async (ctx: any, task: any) => {
        try {
          await kube.checkKubeApi()
          ctx.isOpenShift = await kube.isOpenShift()
          task.title = await `${task.title}...OK`
          if (ctx.isOpenShift) {
            task.title = await `${task.title} (it's OpenShift)`
          }
        } catch (error) {
          command.error(`Failed to connect to Kubernetes API. ${error.message}`)
        }
      }
    }
  }
  /**
   * Returns tasks list which perform preflight platform checks.
   */
  startTasks(flags: any, command: Command): Listr {
    return new Listr([
      {
        title: 'Verify if oc is installed',
        task: (_ctx: any, task: any) => {
          if (!commandExists.sync('oc')) {
            command.error('E_REQUISITE_NOT_FOUND')
          } else {
            task.title = `${task.title}...done.`
          }
        }
      },
      {
        title: 'Verify if openshift is running',
        task: async (_ctx: any, task: any) => {
          const openshiftIsRunning = await this.isOpenshiftRunning()
          if (!openshiftIsRunning) {
            command.error(`E_PLATFORM_NOT_READY: oc status command failed. If there is no project, please create it before by running "oc new-project ${flags.chenamespace}"`)
          } else {
            task.title = `${task.title}...done.`
          }
        }
      },
    ], { renderer: flags['listr-renderer'] as any })
  }

  async isOpenshiftRunning(): Promise<boolean> {
    const { exitCode } = await execa('oc', ['status'], { timeout: 60000, reject: false })
    return exitCode === 0
  }

}
