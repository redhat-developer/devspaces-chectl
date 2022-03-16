/*********************************************************************
 * Copyright (c) 2019-2021 Red Hat, Inc.
 *
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 **********************************************************************/

'use strict'

const fs = require('fs-extra')
const path = require('path')
var deployFolder = path.join(__dirname, 'node_modules', 'devspaces-operator', 'devspaces-operator', 'deploy')
var configFolder = path.join(__dirname, 'node_modules', 'devspaces-operator', 'devspaces-operator', 'config')
var cheOperatorTemplates = path.join(__dirname, 'templates', 'devspaces-operator')

function prepareTemplates() {
    if (fs.existsSync(deployFolder)) {
        fs.copySync(deployFolder, cheOperatorTemplates)
    } else if (fs.existsSync(configFolder)) {
        const filterFunc = (src) => {
            var isFile = fs.statSync(src).isFile()
            if (isFile) {
                var filePath = path.basename(src)
                if (filePath === 'role.yaml' ||
                    filePath === 'role_binding.yaml' ||
                    filePath === 'cluster_role.yaml' ||
                    filePath === 'cluster_rolebinding.yaml' ||
                    filePath === 'service_account.yaml') {
                    return true
                }
            } else {
                var dirName = path.basename(src)
                if (dirName === 'rbac') {
                    return true
                }
            }
        }

        fs.copySync(path.join(configFolder, 'rbac'), cheOperatorTemplates, filterFunc)
        fs.copySync(path.join(configFolder, 'manager', 'manager.yaml'), path.join(cheOperatorTemplates, 'operator.yaml'))
        fs.copySync(path.join(configFolder, 'crd', 'bases'), path.join(cheOperatorTemplates, 'crds'))
        fs.copySync(path.join(configFolder, 'samples', 'org.eclipse.che_v1_checluster.yaml'), path.join(cheOperatorTemplates, 'crds', 'org_v1_che_cr.yaml'))
    } else {
        throw new Error("Unable to prepare devspaces-operator templates")
    }
}

fs.removeSync(cheOperatorTemplates)
prepareTemplates()
