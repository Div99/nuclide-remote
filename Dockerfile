FROM debian:jessie

COPY rootf /usr/local/bin

ENV IMAGE_WATCHMAN_VERSION=v4.9.0 \
    HOME=/root
    
ENV IMAGE_NUCLIDE_VERSION=0.357.0 \
    HOME=/root
    
# Configure Node.js repository
RUN node_setup_8.x

# System packages required
RUN install_packages nodejs  gcc make automake autoconf git python-dev libpython-dev

# Install Watchman
RUN git clone https://github.com/facebook/watchman.git \
	&& cd watchman \
	&& git checkout ${IMAGE_WATCHMAN_VERSION} \
	&& ./autogen.sh \
	&& ./configure \
	&& make && make install
    
# Install SSH server
RUN install_packages openssh-server && mkdir /var/run/sshd

# SSHD scrubs the environment
# http://stackoverflow.com/questions/36292317/why-set-visible-now-in-etc-profile
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Install Nuclide Remote Server
RUN npm install -g nuclide@${IMAGE_NUCLIDE_VERSION} && \
    rm -rf /root/.npm/*

COPY rootfs /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
