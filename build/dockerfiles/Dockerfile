# Copyright (c) 2021-2023 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

# https://registry.access.redhat.com/ubi9/nodejs-18
FROM registry.access.redhat.com/ubi9/nodejs-18:1 as builder
# hadolint ignore=DL3002
USER 0

ARG SEGMENT_WRITE_KEY=INSERT_KEY_HERE \
    DSC_SHORT_VERSION="3.10.0" \
    DSC_PLATFORMS="linux-x64,darwin-x64,darwin-arm64,win32-x64"
ENV SEGMENT_WRITE_KEY=${SEGMENT_WRITE_KEY} \
    DSC_PLATFORMS=${DSC_PLATFORMS} \
    DSC_SHORT_VERSION=${DSC_SHORT_VERSION}

WORKDIR /dsc/
# NOTE: when we move to node 18.17 or 20, can move up to npm@10
RUN dnf -y -q update --exclude=unbound-libs; \
    # subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms; \
    # NOTE: need 7zip to build dsc for windows
    dnf -y -q install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf -y -q --enablerepo=epel install p7zip && \
    # WORKAROUND https://github.com/oclif/oclif/blob/main/src/tarballs/node.ts#L27 -- symlink 7za as 7z
    ln -s /usr/bin/7za /usr/bin/7z
RUN npm i -g yarn@1 oclif@3 npm@9
RUN \
    cd /; git clone --depth 1 https://github.com/redhat-developer/devspaces-chectl dsc && cd dsc/; \
    rm -fr lib/ node_modules/ templates/ tmp/ tsconfig.tsbuildinfo dist/; \
    echo "Insert SEGMENT_WRITE_KEY = $SEGMENT_WRITE_KEY into src/hooks/analytics/analytics.ts"; \
    sed -i "s|INSERT-KEY-HERE|${SEGMENT_WRITE_KEY}|g" src/hooks/analytics/analytics.ts; \
    # WORKAROUND https://github.com/oclif/oclif/blob/main/src/tarballs/node.ts#L70 -- replace 'shasum -a 256 -c -' with 'sha256sum -c -'
    echo "#!/bin/sh" > /usr/bin/shasum; \
    echo "shift 2; sha256sum \$*" >> /usr/bin/shasum; chmod +x /usr/bin/shasum
RUN yarn && npx oclif pack tarballs -t ${DSC_PLATFORMS} --no-xz --parallel
RUN rm -fr coverage/ lib/ node_modules/ templates/ tmp/; \
    # create sources tarball in the same dir with same name as the per-arch binaries
    DSC_FULL_VERSION="$(cat dist/dsc-*linux-x64-buildmanifest | grep -E "tar.gz" | sed -r -e "s@.+/(.+)-linux-x64.+@\1@")"; \
    tar czf dist/${DSC_FULL_VERSION}-sources.tar.gz \
        --exclude=./bin --exclude=./dist ./* && \
    # TODO rename to devspaces-3.10.0-dsc-linux-arm64.tar.gz and devspaces-3.10.0-dsc-sources.tar.gz
    for d in dist/*.gz; do mv $d ${d/${DSC_FULL_VERSION}/dsc-${DSC_SHORT_VERSION}}; done; \
    mv dist/*gz /tarballs/; \
    rm -fr /dsc/

WORKDIR /tarballs/
