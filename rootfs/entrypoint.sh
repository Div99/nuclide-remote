#!/bin/bash
set -e

# Set defaults
export USERNAME=${USERNAME:-"root"}
export PASSWORD=${PASSWORD:-"nuclide"}

if [[ "$1" == "/usr/sbin/sshd" ]]; then
    # Create SSHD username if not exist
    if [[ -z $(getent passwd ${USERNAME}) ]]; then
        echo " --> Creating user ${USERNAME}:${PASSWORD}"
        useradd -m ${USERNAME}
    fi

    # Changing user password
    echo " --> Setting user password ${USERNAME}:${PASSWORD}"
    echo "${USERNAME}:${PASSWORD}" | chpasswd

    # Configure SSHD
    echo " --> Configuring SSHD"
    # Avoid crashing issues
    # http://stackoverflow.com/questions/21391142/why-is-it-needed-to-set-pam-loginuid-to-its-optional-value-with-docker
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
    # Allow root login
    if [[ "$USERNAME" == "root" ]]; then
        sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    fi

    # Configure authorized_keys
    if [[ -n "$AUTHORIZED_KEYS" ]]; then
        USERHOME=`eval echo ~$USERNAME`
        echo " --> Writing ${USERHOME}/.ssh/authorized_keys"
        mkdir ${USERHOME}/.ssh
        chmod 700 ${USERHOME}/.ssh
        echo "$AUTHORIZED_KEYS" | base64 -d > ${USERHOME}/.ssh/authorized_keys
        chmod 600 ${USERHOME}/.ssh/authorized_keys
        chown -R ${USERNAME}: ${USERHOME}/.ssh
    fi

    # Update nuclide module
    if [[ -n "$NUCLIDE_VERSION" ]]; then
        echo " --> Uninstalling current nuclide module"
        # Clean dependencies to avoid installation issues
        npm uninstall -g nuclide
        echo " --> Installing nuclide@${NUCLIDE_VERSION} module"
        npm install -g nuclide@$NUCLIDE_VERSION
    fi
fi

echo " --> Executing $@"
"$@"
