#!/usr/bin/env bash

set -eu

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
#
# stemcell metadata/upload
#

STEMCELL_OS=$(bosh int ${ROOT}/git-kubo-deployment/manifests/cfcr.yml --path /stemcells/0/os)
STEMCELL_VERSION=$(bosh int ${ROOT}/git-kubo-deployment/manifests/cfcr.yml --path /stemcells/0/version)

# KUBO_VERSION="$(cat kubo-version/version)"
pushd ${ROOT}/git-kubo-deployment/manifests
export RELEASES=""
for rel in $RELEASE_LIST
do
  release_url=$(bosh int cfcr.yml -o ops-files/non-precompiled-releases.yml --path=/releases/name=$rel/url)
  release_version=$(bosh int cfcr.yml -o ops-files/non-precompiled-releases.yml --path=/releases/name=$rel/version)
  RELEASES="$RELEASES- name: $rel\n  url: ${release_url}\n  version: ${release_version}\n"
done
popd
# cat > kubo-version.yml <<EOF
# ---
# - type: replace
#   path: /releases/name=kubo
#   value:
#     name: kubo
#     version: "${KUBO_VERSION}"
# EOF

cat > compilation-manifest/manifest.yml <<EOF
---
name: compilation
releases:
$(echo -e "${RELEASES}")
stemcells:
- alias: default
  os: ${STEMCELL_OS}
  version: ${STEMCELL_VERSION}
update:
  canaries: 1
  max_in_flight: 1
  canary_watch_time: 1000 - 90000
  update_watch_time: 1000 - 90000
instance_groups: []
EOF

# bosh int manifest.yml -o kubo-version.yml > compilation-manifest/manifest.yml
