# Copyright Mondoo, Inc. 2026, 0
# SPDX-License-Identifier: BUSL-1.1

# openSUSE Leap test image for molecule, built locally (amd64 and arm64).
# The base image ships neither systemd nor Python, both are needed by molecule.
ARG LEAP_VERSION=16.0
FROM opensuse/leap:${LEAP_VERSION}

RUN zypper --non-interactive refresh \
    && zypper --non-interactive install --no-recommends \
        ca-certificates \
        curl \
        gpg2 \
        gzip \
        hostname \
        iproute2 \
        python3 \
        sudo \
        systemd \
        tar \
        which \
    && zypper clean --all

# Remove units that fail or hang inside a container.
RUN find /usr/lib/systemd/system/sysinit.target.wants/ -mindepth 1 \
        -not -name 'systemd-tmpfiles-setup.service' -delete \
    && rm -f /usr/lib/systemd/system/multi-user.target.wants/* \
        /usr/lib/systemd/system/local-fs.target.wants/* \
        /usr/lib/systemd/system/sockets.target.wants/*udev* \
        /usr/lib/systemd/system/sockets.target.wants/*initctl* \
        /usr/lib/systemd/system/basic.target.wants/* \
        /etc/systemd/system/*.wants/*

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
