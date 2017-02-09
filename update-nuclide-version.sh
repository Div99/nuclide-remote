#!/bin/bash

# Query GitHub API to get the latest stable tag
curl -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" \
     -s https://api.github.com/repos/facebook/nuclide/tags | \
    jq .[].name | \
    sort -r | \
    grep -v rc | \
    head -n1 | \
    tr -d v\" | \
    xargs -I % sed "s/ENV\s*IMAGE_NUCLIDE_VERSION=.*/ENV IMAGE_NUCLIDE_VERSION=% \\\/g" -i Dockerfile
