FROM #{FROM}

LABEL #{LABEL}

#{ROOTFS}
#{QEMU}

COPY resolv.conf /etc/resolv.conf
RUN mkdir -p /etc/yum/vars \
    && echo "armhfp" > /etc/yum/vars/basearch \
    && sed -i s~^executable=.*~executable=\"/usr/bin/yum-deprecated\"~g /usr/bin/yum

RUN rpm --rebuilddb && yum install -y \
        ca-certificates tar \
        systemd \
    && yum clean all

# Install Systemd

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# We never want these to run in a container.
# Also disable some unnecessary service in Fedora base images.
# ref: http://vpavlin.eu/2015/02/fedora-docker-and-systemd/
# http://developerblog.redhat.com/2014/05/05/running-systemd-within-docker-container/
# https://fedorahosted.org/spin-kickstarts/ticket/54
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
        tmp.mount \
        console-getty.service \
        auditd \
    && rm -f /etc/systemd/system/default.target \
    && ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target \
    && cat /dev/null > /etc/fstab

COPY entry.sh /usr/bin/entry.sh
COPY launch.service /etc/systemd/system/launch.service

RUN systemctl enable /etc/systemd/system/launch.service systemd-udevd

VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT ["/usr/bin/entry.sh"]
