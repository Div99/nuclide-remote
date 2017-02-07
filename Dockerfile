FROM bitnami/minideb
MAINTAINER Joseda <josriolop@gmail.com>

ENV HOME /root

# Install and configre SSH server
RUN install_packages openssh-server && \
    mkdir /var/run/sshd && \
    echo 'root:nuclide' | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# SSHD scrubs the environment
# http://stackoverflow.com/questions/36292317/why-set-visible-now-in-etc-profile
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Install Node.js
RUN install_packages curl ca-certificates && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    install_packages nodejs

# Install Watchman
ENV WATCHMAN_VERSION v4.5.0
RUN install_packages gcc make autoconf git python-dev libpython-dev autotools-dev automake && \
    git clone https://github.com/facebook/watchman.git && \
    cd watchman && \
    git checkout ${WATCHMAN_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    apt-get purge -y gcc make autoconf git python-dev libpython-dev autotools-dev automake

# Install Nuclide Remote Server
RUN npm install -g nuclide

COPY rootfs /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
