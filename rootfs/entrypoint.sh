#!/bin/bash
set -e

if [[ "$1" == "/usr/sbin/sshd" ]]; then
    if [[ -z "$NUCLIDE_VERSION" ]]; then
        modules="nuclide"
    else
        modules="nuclide@$NUCLIDE_VERSION"
    fi
    echo " --> Installing $modules..."
    npm install -g $modules
fi

echo " --> Executing $@"
"$@"
