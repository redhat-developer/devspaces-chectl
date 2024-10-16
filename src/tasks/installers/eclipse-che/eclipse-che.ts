/**
 * Copyright (c) 2019-2022 Red Hat, Inc.
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *   Red Hat, Inc. - initial API and implementation
 */

export namespace EclipseChe {
  export const CHE_FLAVOR = 'devspaces'
  export const PRODUCT_ID = 'devspaces'
  export const PRODUCT_NAME = 'Red Hat OpenShift Dev Spaces'

  // Resources
  export const NAMESPACE = 'openshift-devspaces'
  export const OPERATOR_SERVICE = `${CHE_FLAVOR}-operator-service`
  export const OPERATOR_SERVICE_CERT_SECRET = `${CHE_FLAVOR}-operator-service-cert`
  export const OPERATOR_SERVICE_ACCOUNT = `${CHE_FLAVOR}-operator`
  export const K8S_CERTIFICATE = 'che-operator-serving-cert'
  export const K8S_ISSUER = 'che-operator-selfsigned-issuer'
  export const VALIDATING_WEBHOOK = 'org.eclipse.che'
  export const MUTATING_WEBHOOK = 'org.eclipse.che'
  export const CONFIG_MAP = 'che'
  export const PLUGIN_REGISTRY_CONFIG_MAP = 'plugin-registry'
  export const CONSOLE_LINK = 'che'
  export const PROMETHEUS = 'prometheus-k8s'
  export const IMAGE_CONTENT_SOURCE_POLICY = 'quay.io'

  // API
  export const CHE_CLUSTER_CRD = 'checlusters.org.eclipse.che'
  export const CHE_CLUSTER_API_GROUP = 'org.eclipse.che'
  export const CHE_CLUSTER_API_VERSION_V2 = 'v2'
  export const CHE_CLUSTER_KIND_PLURAL = 'checlusters'

  // OLM
  export const PACKAGE = PRODUCT_ID
  export const STABLE_CHANNEL = 'stable'
  export const STABLE_CHANNEL_CATALOG_SOURCE = 'redhat-operators'
  export const NEXT_CHANNEL = 'fast'
  export const NEXT_CHANNEL_CATALOG_SOURCE = 'devspaces-fast'
  export const NEXT_CATALOG_SOURCE_IMAGE = 'quay.io/eclipse/eclipse-che-olm-catalog:next'
  export const SUBSCRIPTION = 'devspaces-subscription'
  export const CSV_PREFIX = 'devspacesoperator'
  export const APPROVAL_STRATEGY_MANUAL = 'Manual'
  export const APPROVAL_STRATEGY_AUTOMATIC = 'Automatic'

  // TLS
  export const CHE_TLS_SECRET_NAME = 'che-tls'
  export const SELF_SIGNED_CERTIFICATE = 'self-signed-certificate'
  export const DEFAULT_CA_CERT_FILE_NAME = 'cheCA.crt'

  // Operator image
  export const OPERATOR_IMAGE_NAME = 'quay.io/eclipse/che-operator'
  export const OPERATOR_IMAGE_NEXT_TAG = 'next'

  // Doc links
  export const DOC_LINK = 'https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.18/'
  export const DOC_LINK_RELEASE_NOTES = 'https://access.redhat.com/documentation/en-us/red_hat_openshift_dev_spaces/3.18/html/release_notes_and_known_issues/index'
  export const DOC_LINK_CONFIGURE_API_SERVER = 'https://kubernetes.io/docs/reference/access-authn-authz/authentication/#configuring-the-api-server'

  // Components
  export const CHE_SERVER = `${PRODUCT_NAME} Server`
  export const DASHBOARD = 'Dashboard'
  export const GATEWAY = 'Gateway'
  export const PLUGIN_REGISTRY = 'Plugin Registry'
  export const CHE_OPERATOR = `${PRODUCT_NAME} Operator`

  // Deployments
  export const OPERATOR_DEPLOYMENT_NAME = `${CHE_FLAVOR}-operator`
  export const CHE_SERVER_DEPLOYMENT_NAME = `${CHE_FLAVOR}`
  export const DASHBOARD_DEPLOYMENT_NAME = `${CHE_FLAVOR}-dashboard`
  export const GATEWAY_DEPLOYMENT_NAME = 'che-gateway'
  export const PLUGIN_REGISTRY_DEPLOYMENT_NAME = 'plugin-registry'

  // Selectors
  // It must be `app=`, see: https://issues.redhat.com/browse/CRW-4848
  export const CHE_OPERATOR_SELECTOR = `app=${CHE_FLAVOR}-operator,app.kubernetes.io/component=${CHE_FLAVOR}-operator`

  export const CHE_SERVER_SELECTOR = `app.kubernetes.io/name=${CHE_FLAVOR},app.kubernetes.io/component=${CHE_FLAVOR}`
  export const DASHBOARD_SELECTOR = `app.kubernetes.io/name=${CHE_FLAVOR},app.kubernetes.io/component=${CHE_FLAVOR}-dashboard`
  export const PLUGIN_REGISTRY_SELECTOR = `app.kubernetes.io/name=${CHE_FLAVOR},app.kubernetes.io/component=plugin-registry`
  export const GATEWAY_SELECTOR = `app.kubernetes.io/name=${CHE_FLAVOR},app.kubernetes.io/component=che-gateway`
}
