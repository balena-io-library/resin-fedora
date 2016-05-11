FROM #{FROM}

LABEL #{LABEL}

#{ROOTFS}
#{QEMU}

COPY resolv.conf /etc/resolv.conf
