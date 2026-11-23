# sentin8 packaging
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](../LICENSE)
[![Built with Rust](https://img.shields.io/badge/Built%20with-Rust-orange.svg)](https://www.rust-lang.org/)
[![Docs](https://img.shields.io/badge/docs/read-3aa757.svg)](https://sentin8.dev/docs/services/packaging)
[![Website](https://img.shields.io/badge/website-sentin8.dev-1a73e8.svg)](https://sentin8.dev)

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

## Ports the runtime binds

The packaged unit runs the fleet as the unprivileged `sentin8` user, yet the
ingress must hold `443` (and `80` when external certificate issuance is
enabled). The unit grants `CAP_NET_BIND_SERVICE` through
`CapabilityBoundingSet`/`AmbientCapabilities`; captain inherits the ambient set
and passes it to the proxy it spawns. No service runs as root, and no install
step is required beyond the package.

`setcap` on the binary is deliberately not used: the unit sets
`NoNewPrivileges=yes`, under which file capabilities are ignored at `execve`,
and the xattr would not survive `dpkg` upgrades. A source/dev host instead
lowers `net.ipv4.ip_unprivileged_port_start` to `80`, because cargo rebuilds
produce a new inode per build. See `DESIGN.md` §4.1.

The ingress port itself is fixed at `443`; the platform's discovery documents,
issuer values, DPoP proofs, cookies, and SDK URL builders all derive
scheme-default URLs, so reach on a different port is a host-level mapping
decision, never a listener change.

---

**Architecture & Design:** sentin8:packaging and its underlying concepts were designed by [Hamid Jahanzad](https://www.linkedin.com/in/hamidjahanzad/).
