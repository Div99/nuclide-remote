#!/bin/bash
set -e

# Set defaults
export SYSTEM_USERNAME=${SYSTEM_USERNAME:-"root"}
export SYSTEM_PASSWORD=${SYSTEM_PASSWORD:-"nuclide"}

if [[ "$1" == "/usr/sbin/sshd" ]]; then
    # Create SSHD username if not exist
    if [[ -z $(getent passwd ${SYSTEM_USERNAME}) ]]; then
        echo " --> Creating user ${SYSTEM_USERNAME}:${SYSTEM_PASSWORD}"
        useradd -m ${SYSTEM_USERNAME}
    fi

    # Changing user password
    echo " --> Setting user password ${SYSTEM_USERNAME}:${SYSTEM_PASSWORD}"
    echo "${SYSTEM_USERNAME}:${SYSTEM_PASSWORD}" | chpasswd

    # Configure SSHD
    echo " --> Configuring SSHD"
    sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

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
