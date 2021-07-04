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

import { Command } from '@oclif/command'

/**
 * Update command to display download instructions to the user
 */
export default class Update extends Command {
  static description = 'instructions for updating crwctl'

  async run() {
    this.log('To update crwctl, download the latest from https://developers.redhat.com/products/codeready-workspaces/download and install that instead of your current version.')
  }
}
