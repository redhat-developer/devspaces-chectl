# Copyright (c) 2023 Red Hat, Inc.
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

# pass in segment key, x.y.z version, and platforms via --build-arg flags
ARG SEGMENT_WRITE_KEY=INSERT_KEY_HERE \
    CSV_VERSION="3.yy.z" \
    DSC_PLATFORMS="linux-x64"
ENV SEGMENT_WRITE_KEY=${SEGMENT_WRITE_KEY} \
    DSC_PLATFORMS=${DSC_PLATFORMS} \
    CSV_VERSION=${CSV_VERSION}

WORKDIR /dsc-build/

# hadolint ignore=DL3003,DL3040,SC2164,DL3041
RUN \
    dnf -y -q update --exclude=unbound-libs; \
    # subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms; \
    # NOTE: need 7zip to build dsc for windows
    dnf -y -q install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf -y -q --enablerepo=epel install p7zip && \
    # WORKAROUND https://github.com/oclif/oclif/blob/main/src/tarballs/node.ts#L27 -- symlink 7za as 7z
    ln -s /usr/bin/7za /usr/bin/7z; \
    # NOTE: when we move to node 18.17 or 20, can use npm@10
    npm i -g yarn@1 oclif@3 npm@9; \
    cd /; git clone --depth 1 https://github.com/redhat-developer/devspaces-chectl dsc-build && cd dsc-build/; \
    rm -fr lib/ node_modules/ templates/ tmp/ tsconfig.tsbuildinfo dist/; \
    echo "Insert SEGMENT_WRITE_KEY = $SEGMENT_WRITE_KEY into src/hooks/analytics/analytics.ts"; \
    sed -i "s|INSERT-KEY-HERE|${SEGMENT_WRITE_KEY}|g" src/hooks/analytics/analytics.ts; \
    # WORKAROUND https://github.com/oclif/oclif/blob/main/src/tarballs/node.ts#L62 -- replace 'shasum -a 256 -c -' with 'sha256sum -c -'
    echo "#!/bin/sh" > /usr/bin/shasum; echo "shift 2; sha256sum \$*" >> /usr/bin/shasum; chmod +x /usr/bin/shasum

# build dsc tarballs
RUN yarn && echo "Build dsc binaries for these arches: ${DSC_PLATFORMS}"; yarn pack-binaries -t ${DSC_PLATFORMS}

# hadolint ignore=DL4006,SC2086
RUN \
    # delete temp files before creating sources tarball
    rm -fr coverage/ lib/ node_modules/ templates/ tmp/; \
    # create sources tarball in the same dir with same name as the per-arch binaries
    DSC_FULL_VERSION="$(cat dist/dsc-*linux-x64-buildmanifest | grep -E "tar.gz" | sed -r -e "s@.+/(.+)-linux-x64.+@\1@")"; \
    if [[ ! $DSC_FULL_VERSION ]]; then DSC_FULL_VERSION="dsc"; fi
    echo "Got DSC_FULL_VERSION = $DSC_FULL_VERSION"; \
    tar czf dist/${DSC_FULL_VERSION}-sources.tar.gz --exclude=./bin --exclude=./dist ./* && \
    # rename long names to devspaces-3.10.0-dsc-linux-arm64.tar.gz and devspaces-3.10.0-dsc-sources.tar.gz
    for d in $(find dist/ -name "*.gz"); do \
        mv $d ${d/${DSC_FULL_VERSION}/dsc-${CSV_VERSION}}; \
    done

# https://registry.access.redhat.com/ubi9-micro
FROM registry.access.redhat.com/ubi9-micro:9.2
WORKDIR /dsc/
# Note: if we wanted to unpack tarballs within the container, need to install libstdc++.so.6 here to run from within the container.
# Instead, see devfile.yaml for how to fetch, extract from the container, and unpack/install dsc.
COPY --from=builder /dsc-build/dist/*gz /dsc/
