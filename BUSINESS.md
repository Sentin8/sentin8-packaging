# BUSINESS.md: sentin8-packaging — Business Requirements & Functionality

> Audience: product owners, business analysts, and anyone evaluating what
> sentin8-packaging **does for the business**. For the overview read
> `README.md`; for wire-level detail read `DESIGN.md`.

## 1. Business Purpose

sentin8-packaging turns "the platform builds" into "the platform
installs": four Debian packages that put a runnable Sentin8 host on a
machine (or a dev kit on an engineer's workstation) with fixed,
predictable paths — and the single manifest that keeps the split
reviewable. The business value it delivers:

- **Installable fleet hosts.** One `apt install sentin8` + the operator
  env file yields a machine that joins the fleet (the OpenTofu module
  kit's bring-up contract consumes exactly these packages).
- **One reviewable split.** `manifest.yaml` is the data that decides
  what goes in which package — package questions are answered by reading
  one file, not reverse-engineering `debian/` scripts.
- **Verticals build without the platform source.** `sentin8-dev`'s
  vendored registry + SDK sources let vertical workspaces compile
  against pinned artifacts.
- **One supervisor, one unit.** The systemd story is
  `sentin8-captain.service` — the fleet's process model is captain's,
  and packaging does not create a competing one.

## 2. Business Scope (What the Service Provides)

| Area | Capabilities |
|---|---|
| `sentin8-common` | Shared platform data: SQL, registry JSON, web assets (deployed alongside any runtime) |
| `sentin8` | The runtime: all service binaries, env template, the captain systemd unit, logrotate |
| `sentin8-dev` | The build kit: CLI binary, vendored crate registry, SDK sources, cargo-config template |
| `sentin8-postgres-config` | PostgreSQL certificate-identity wiring (TLS-only pg_hba + pgm identity map) for local or remote PG hosts |
| FHS contract | `/etc/sentin8`, `/var/{lib,log}/sentin8`, `/run/sentin8`, `/usr/share/sentin8` — declared once, consumed platform-wide |
| Machine bring-up contract | The deb set an OpenTofu module installs to provision a fleet machine (captain DESIGN §11.5) |

### What packaging does NOT own (business boundary)

| Out of scope | Owner |
|---|---|
| What binaries contain | the service repos (packaging delivers, never builds logic) |
| Process supervision | Sentin8:Captain |
| Provisioning decisions | Sentin8:Captain's autoscaler + operator |
| Secrets | the operator env + provision-time module variables |
| Vertical app packages | vertical group repos (same manifest pattern, their packages) |

## 3. Business Capabilities

| Capability | Business rule |
|---|---|
| Manifest-driven split | Every package boundary, file list, and dependency is declared in `manifest.yaml` — generated install/control files, never hand-maintained |
| Coherent fleet artifacts | One platform package set ships all 16 service binaries together — version skew between services is expressed ONLY at rollout time by captain, never by divergent package states |
| Dev-kit fidelity | The vendored registry pins match the platform SDK tag — dev and packaged builds share the same dependency-resolution model |
| Predictable paths | Every runtime assumption (log dir, secrets dir, TLS state, run dir) is one FHS contract — no per-service path drift |
| Bring-up consumption | The provisioning module kit installs these debs verbatim; packaging's unit + env-file contract is the machine's entire bring-up surface |

## 4. Business Events (Outbound)

None — packaging is an artifact plane. Delivery surface: `apt`
repositories (operator-hosted), the built `.deb` files, and the machine
bring-up contract consumed by the OpenTofu modules.

## 5. Business Rules & Invariants

1. **One manifest to rule the split** — package questions are answered
   in `manifest.yaml`; generated files are never edited.
2. **No competing supervisor** — exactly one systemd unit;
   per-service units do not exist.
3. **No secrets in debs** — templates only; values land at provision
   time.
4. **The dev kit pins what the platform ships** — registry ↔ SDK tag
   coherence is invariant.
5. **FHS paths are the contract** — repos may default to them but may
   not invent new ones.

## 6. Target-User Roles & Use Cases

| Persona | What they do with sentin8-packaging |
|---|---|
| Release engineer | Builds the deb set per release; publishes to the apt repo |
| Platform operator | Installs the runtime on fleet hosts; the machine joins via the operator env file |
| Vertical developer | Installs `sentin8-dev`, builds vertical services against the vendored registry |
| Infra-as-code author | Writes OpenTofu modules that install the debs + materialize the env file |

## 7. KPIs / Success Criteria

- **Install-to-join time**: a fresh machine reaches a captain connected
  to the fleet registry with only package install + env file.
- **Split reviewability**: package changes are manifest diffs — one
  reviewed file per release.
- **Zero secret exposure**: no deb carries a secret, ever.
- **Build reproducibility**: the vendored registry reproduces the
  platform's SDK pin exactly.

## 8. Dependencies & Reliance on Other Services

| The business relies on… | For |
|---|---|
| The platform group's build outputs | 17 service binaries + cli + Flutter web assets |
| Debian tooling | dpkg/debhelper, `cargo vendor` + `cargo local-registry` |
| PostgreSQL 18 | `sentin8-postgres-config` targets its TLS-only hostssl+cert HBA shape |
| OpenTofu module kit | The machine bring-up contract's consumer |

## 9. Acceptance Criteria

1. `apt install sentin8` (with common) yields a bootable host: binaries
   present, user created, unit installed, env template in place.
2. Starting the unit brings up captain; placement/telemetry behavior
   follows the operator env file.
3. `apt install sentin8-dev` lets a vertical workspace build offline
   against the vendored registry.
4. `manifest.yaml`-only changes regenerate correct control/install
   files.
5. No package ships a secret value; lintian passes clean.

## 10. Open Business Questions

- Moving `sentin8-cli` from the dev kit into the runtime package
  (operators on every host) tracks the packaging backlog (SD-7).
- RPM/deb-remote publishing cadence is a deployment decision until a
  consumer demands it.

---

**Design attribution:** sentin8:packaging and its underlying concepts were designed by Hamid Jahanzad <Hamid@Jahanzad.com>.
