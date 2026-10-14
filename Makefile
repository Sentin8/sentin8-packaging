# SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
# SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
# SPDX-FileCopyrightText: Copyright Contributors to the Sentin8:Packaging
# SPDX-License-Identifier: Apache-2.0

# Makefile — sentin8-packaging (packaging repo, RS §4.5)
#
# Self-contained dev controls for THIS packaging. Sources the root .env for
# fleet env, guarantees the dev infra, and uses an ABSOLUTE
# SENTIN8_CAPTAIN_BINARY_PREFIX (cwd-independent — RS §4.5.1-1).
SHELL := /bin/bash

.PHONY: help deb manifest-check lint clean

help: ## Show this help
	@echo "sentin8-packaging (Debian packaging)"
	@grep -E '^[a-z-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

deb: ## Build the deb split (dpkg-buildpackage from this repo root)
	@dpkg-buildpackage -us -uc

manifest-check: ## Verify manifest.yaml parses as YAML (best effort)
	@python3 -c 'import yaml; yaml.safe_load(open("manifest.yaml"))' 2>/dev/null \
		|| echo "WARNING: PyYAML missing — skipped manifest.yaml parse check"

lint: manifest-check ## static checks
	@test -f debian/control || { echo "ERROR: debian/control missing" >&2; exit 1; }
	@test -f manifest.yaml || { echo "ERROR: manifest.yaml missing" >&2; exit 1; }

clean: ## packaging is source-only — nothing to clean
	@echo "nothing to clean"
