# sentin8 packaging

Debian packaging for the sentin8 platform (`sentin8-common`, `sentin8`,
`sentin8-dev`, `sentin8-postgres-config`) plus the shared `manifest.yaml` schema,
FHS conventions, and systemd unit template that verticals consume.

> Docs: `README.md` (overview) · `DESIGN.md` (detailed design) ·
> `BUSINESS.md` (business requirements).

This directory will hold `debian/` (`control`, `rules`, per-package `.install`
files, `sentin8.postinst`, `sentin8.logrotate`, `sentin8-captain.service`) and
`manifest.yaml` (the single source of truth for package split, file lists, FHS
paths, systemd unit, and post-install steps).

`sentin8-dev` ships the vendored cargo local-registry at
`/usr/share/sentin8/registry/` so verticals build without the sentin8 source
repo.

---

**Design attribution:** sentin8:packaging and its underlying concepts were designed by Hamid Jahanzad <Hamid@Jahanzad.com>.
