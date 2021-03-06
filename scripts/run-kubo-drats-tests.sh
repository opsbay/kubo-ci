#!/usr/bin/env bash

set -eu -o pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

main() {
  pushd "${ROOT}/bbr-cli"
    tar xvf bbr-*.tar
  popd

  BOSH_ENVIRONMENT="$(jq -r '.target' "${ROOT}/source-json/source.json")"
  BOSH_CLIENT="$(jq -r '.client' "${ROOT}/source-json/source.json")"
  BOSH_CLIENT_SECRET="$(jq -r '.client_secret' "${ROOT}/source-json/source.json")"
  BOSH_CA_CERT="$(jq -r '.ca_cert' "${ROOT}/source-json/source.json")"
  BOSH_DEPLOYMENT="$DEPLOYMENT_NAME"
  KUBECONFIG="${ROOT}/gcs-kubeconfig/config"
  GOPATH="$PWD"
  PATH="$PATH:${ROOT}/bbr-cli/releases/"

  export BOSH_ENVIRONMENT BOSH_CLIENT BOSH_CLIENT_SECRET BOSH_CA_CERT BOSH_DEPLOYMENT KUBECONFIG GOPATH

  test_path="src/github.com/cloudfoundry-incubator/kubo-disaster-recovery-acceptance-tests/acceptance"
  ginkgo -r -progress "${ROOT}/${test_path}"
}

main
