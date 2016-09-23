FROM #{FROM}

LABEL #{LABEL}

#{QEMU}

COPY resolv.conf /etc/resolv.conf

# Few tweaks for Fedora base image
RUN mkdir -p /etc/dnf/vars \
    && echo "armhfp" > /etc/dnf/vars/basearch \
    && echo "armv7hl" > /etc/dnf/vars/arch \
    && rm -rf /tmp/* \
    && touch /etc/machine-id

RUN dnf update -y \
    && dnf install -y \
        ca-certificates \
        findutils \
        hostname \
        systemd \
        tar \
        udev \
        which \
    && dnf clean all

ENV container docker

RUN systemctl mask \
        dev-hugepages.mount \
        sys-fs-fuse-connections.mount \
        sys-kernel-config.mount \
        display-manager.service \
        getty@.service \
        systemd-logind.service \
        systemd-remount-fs.service \
        getty.target \
        graphical.target \
        console-getty.service \
        systemd-vconsole-setup.service

COPY entry.sh /usr/bin/
COPY launch.service /etc/systemd/system/launch.service

RUN systemctl enable launch.service systemd-udevd

STOPSIGNAL 37
VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT ["/usr/bin/entry.sh"]
