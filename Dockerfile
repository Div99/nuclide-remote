FROM bitnami/minideb

ENV IMAGE_NUCLIDE_VERSION=0.357.0 \
    WATCHMAN_VERSION=v4.9.0 \
    HOME=/root

# Install Miniconda Environment
ENV PATH /opt/conda/bin:$PATH

RUN install_packages wget bzip2 ca-certificates curl git && \
    apt-get clean

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# Install Watchman and System packages required
RUN install_packages libssl-dev pkg-config libtool ca-certificates git build-essential \
    autoconf python-dev libpython-dev autotools-dev automake && \
    \
    git clone https://github.com/facebook/watchman.git &&  \
    cd watchman && \
    git checkout ${WATCHMAN_VERSION} && \
    ./autogen.sh && \
    ./configure && \
    make && make install && \
    \
    apt-get remove --purge -y libssl-dev pkg-config libtool build-essential autoconf \
    python-dev libpython-dev autotools-dev automake && \
    apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && \
    cd / && rm -rf watchman

# Install SSH server
RUN install_packages openssh-server && mkdir /var/run/sshd

# SSHD scrubs the environment
# http://stackoverflow.com/questions/36292317/why-set-visible-now-in-etc-profile
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Install Node.js
RUN install_packages curl ca-certificates gnupg2 && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    install_packages nodejs

# Install Nuclide Remote Server
RUN npm install -g nuclide@${IMAGE_NUCLIDE_VERSION} && \
    rm -rf /root/.npm/*

COPY rootfs /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
