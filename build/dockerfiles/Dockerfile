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
    DSC_PLATFORMS="linux-x64,darwin-x64,darwin-arm64,win32-x64"
ENV SEGMENT_WRITE_KEY=${SEGMENT_WRITE_KEY} \
    DSC_PLATFORMS=${DSC_PLATFORMS}

WORKDIR /dsc/
# NOTE: when we move to node 18.17 or 20, can move up to npm@10
RUN dnf -y -q update --exclude=unbound-libs; \
    subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms; \
    # NOTE: need RHEL 8 for 7zip; need 7zip to build dsc for windows
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
RUN mv dist/channels/*redhat dist/channels/redhat; ls -la dist/channels/redhat/
    # copy from generic name specific name, so E2E/CI jobs can access tarballs from generic folder and filename (name doesn't change between builds)
    # while IFS= read -r -d '' d; do; \
    #     e=${d/redhat\/dsc/redhat\/${TARBALL_PREFIX}-dsc}; \
    #     cp ${d} ${e}; \
    # done <   <(find dist/channels/redhat -type f -name "*gz" -print0); \

    # purge generated binaries and temp files
RUN rm -fr coverage/ lib/ node_modules/ templates/ tmp/; \

    # create sources tarball in the same dir where we have the per-arch binaries
    tar czf /tmp/${TARBALL_PREFIX}-dsc-sources.tar.gz --exclude=./dist/channels/*/* ./* && \
    mv /tmp/${TARBALL_PREFIX}-dsc-sources.tar.gz ${DSC_DIR}/dist/channels/redhat/; \

    pwd; du ./dist/channels/*/*gz

# FROM scratch as runtime
# WORKDIR /dsc
# # COPY --from:builder /dsc/* /dsc/
# ENTRYPOINT ["/dsc/bin/dsc"]

## Append Brew metadata
