#!/usr/bin/env bash
set -euo pipefail

repo=${DUSKLIGHT_UPSTREAM_REPO:-TwilitRealm/dusklight}

current_pkgver=$(
  # shellcheck source=/dev/null
  source PKGBUILD
  printf '%s\n' "${pkgver}"
)

curl_args=(-fsSL)
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl_args+=(
    -H "Authorization: Bearer ${GITHUB_TOKEN}"
    -H 'X-GitHub-Api-Version: 2022-11-28'
  )
fi

latest_tag=$(
  curl "${curl_args[@]}" "https://api.github.com/repos/${repo}/releases/latest" |
    python -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])'
)
latest_pkgver=${latest_tag#v}

if [[ "${latest_tag}" == "${latest_pkgver}" ]]; then
  printf 'Latest release tag %s does not start with v\n' "${latest_tag}" >&2
  exit 1
fi

if [[ "${latest_pkgver}" == "${current_pkgver}" ]]; then
  printf 'dusklight-bin is already up to date at %s\n' "${current_pkgver}"
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    {
      printf 'changed=false\n'
      printf 'pkgver=%s\n' "${current_pkgver}"
    } >>"${GITHUB_OUTPUT}"
  fi
  exit 0
fi

printf 'Updating dusklight-bin from %s to %s\n' "${current_pkgver}" "${latest_pkgver}"

sed -i \
  -e "s/^pkgver=.*/pkgver=${latest_pkgver}/" \
  -e 's/^pkgrel=.*/pkgrel=1/' \
  PKGBUILD

updpkgsums
makepkg --printsrcinfo > .SRCINFO
makepkg --verifysource

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    printf 'changed=true\n'
    printf 'pkgver=%s\n' "${latest_pkgver}"
  } >>"${GITHUB_OUTPUT}"
fi
