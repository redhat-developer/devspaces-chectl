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

import { OperatorTasks } from './operator'

/**
 * Tasks related to installation way.
 */
export class InstallerTasks {
  updateTasks(flags: any, command: Command): ReadonlyArray<Listr.ListrTask> {
    const operatorTasks = new OperatorTasks()

    let title: string
    let task: any

    // let task: Listr.ListrTask
    if (flags.installer === 'operator') {
      title = '�‍  Running the CodeReady Workspaces operator update'
      task = () => {
        return operatorTasks.updateTasks(flags, command)
      }
    } else {
      title = '🏃‍  Installer preflight check'
      task = () => { command.error(`Installer ${flags.installer} does not support update ¯\\_(ツ)_/¯`) }
    }

    return [{
      title,
      task
    }]
  }

  preUpdateTasks(flags: any, command: Command): ReadonlyArray<Listr.ListrTask> {
    const operatorTasks = new OperatorTasks()

    let title: string
    let task: any

    // let task: Listr.ListrTask
    if (flags.installer === 'operator') {
      title = '�‍  Running the CodeReady Workspaces operator update'
      task = () => {
        return operatorTasks.preUpdateTasks(flags, command)
      }
    } else {
      title = '🏃‍  Installer preflight check'
      task = () => { command.error(`Installer ${flags.installer} does not support update ¯\\_(ツ)_/¯`) }
    }

    return [{
      title,
      task
    }]
  }

  installTasks(flags: any, command: Command): ReadonlyArray<Listr.ListrTask> {
    const operatorTasks = new OperatorTasks()

    let title: string
    let task: any

    // let task: Listr.ListrTask
    if (flags.installer === 'operator') {
      title = '�‍  Running the CodeReady Workspaces operator'
      task = () => {
        // The operator installs CodeReady Workspaces multiuser only
        if (!flags.multiuser) {
          command.warn('CodeReady Workspaces can only be deployed in Multi-User mode.')
          flags.multiuser = true
        }

        return operatorTasks.startTasks(flags, command)
      }
    } else {
      title = '🏃‍  Installer preflight check'
      task = () => { command.error(`Installer ${flags.installer} is not supported ¯\\_(ツ)_/¯`) }
    }

    return [{
      title,
      task
    }]
  }
}
