# dusklight-bin

AUR package files for Dusklight. This package installs the upstream Linux x86_64 AppImage and desktop integration instead of building Dusklight from source.

## Local Test

```sh
makepkg --verifysource
makepkg -si
```

The package installs:

- `/opt/dusklight/dusklight.AppImage`
- `/usr/bin/dusklight`
- `/usr/share/applications/dusklight.desktop`
- hicolor icons under `/usr/share/icons/hicolor`

## Updating

1. Set `pkgver` in `PKGBUILD` to the new upstream version without the `v` prefix.
2. Reset `pkgrel` to `1`.
3. Run `updpkgsums`.
4. Run `makepkg --printsrcinfo > .SRCINFO`.
5. Run `makepkg --verifysource`.
6. Commit `PKGBUILD` and `.SRCINFO` to the AUR `dusklight-bin` repository.

Only `x86_64` is listed because upstream currently publishes a Linux x86_64 AppImage.

## Automated Updates

The GitHub Actions workflow in `.github/workflows/update-aur.yml` checks the latest upstream GitHub release every 6 hours and on manual dispatch. When a newer release exists, it:

- updates `pkgver` and resets `pkgrel`
- regenerates checksums with `updpkgsums`
- regenerates `.SRCINFO`
- verifies sources with `makepkg --verifysource`
- commits and pushes the package repo
- creates and pushes a matching `v<version>` Git tag, such as `v1.1.1`
- pushes the same commit to AUR

Repository requirements:

- Enable GitHub Actions write access for `GITHUB_TOKEN` if the repository settings require it.
- Add a repository secret named `AUR_SSH_PRIVATE_KEY` containing the private SSH key allowed to push to `ssh://aur@aur.archlinux.org/dusklight-bin.git`.
- Add the matching public key to the AUR account that maintains `dusklight-bin`.

Manual workflow dispatch also pushes the current package state to AUR, even when there is no new upstream release. This makes it useful for retrying a failed AUR sync.
