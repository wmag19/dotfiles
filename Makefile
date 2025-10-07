# Makefile for managing dotfiles with GNU Stow
# - stow-config: manage packages under ./.config -> $(HOME)/.config
# - stow-system: manage packages under ./system -> / (e.g. /etc)

STOW ?= stow
SUDO ?= sudo
VERBOSITY ?= 1
HOME_DIR ?= $(HOME)
CURDIR := $(shell pwd)

.PHONY: help stow stow-config stow-system restow restow-config restow-system \
  delete delete-config delete-system dry-run dry-run-config dry-run-system

# If PKG is provided, operate only on that package. Otherwise auto-detect.
ifdef PKG
CONFIG_PKGS := $(PKG)
SYSTEM_PKGS := $(PKG)
else
CONFIG_PKGS := $(patsubst .config/%/,%,$(wildcard .config/*/))
SYSTEM_PKGS := $(patsubst system/%/,%,$(wildcard system/*/))
endif

help:
	@printf "Usage:\n"
	@printf "  make stow           # stow both .config and system packages\n"
	@printf "  make stow-config    # stow packages from .config into $(HOME_DIR)/.config\n"
	@printf "  make stow-system    # stow packages from system into / (may use sudo)\n"
	@printf "  make restow         # restow both\n"
	@printf "  make delete         # delete both\n"
	@printf "\nOptions:\n"
	@printf "  VERBOSITY=n   set stow verbosity (0-4) [default $(VERBOSITY)]\n"
	@printf "  SUDO=         override sudo (set to empty to avoid sudo)\n"
	@printf "  PKG=name      operate on a single package instead of all detected\n"

# Top-level convenience targets
stow: stow-config stow-system

# Stow into ~/.config
stow-config:
	@echo "Stowing config packages: $(CONFIG_PKGS) -> $(HOME_DIR)/.config"
	$(STOW) --dir=$(CURDIR)/.config --target=$(HOME_DIR)/.config --verbose=$(VERBOSITY) $(CONFIG_PKGS)

# Stow into / (use SUDO by default because /etc often requires root)
stow-system:
	@echo "Stowing system packages: $(SYSTEM_PKGS) -> /"
	$(SUDO) $(STOW) --dir=$(CURDIR)/system --target=/ --verbose=$(VERBOSITY) $(SYSTEM_PKGS)

# Restow helpers
restow-config:
	@echo "Restowing config packages: $(CONFIG_PKGS) -> $(HOME_DIR)/.config"
	$(STOW) --dir=$(CURDIR)/.config --target=$(HOME_DIR)/.config --restow --verbose=$(VERBOSITY) $(CONFIG_PKGS)

restow-system:
	@echo "Restowing system packages: $(SYSTEM_PKGS) -> /"
	$(SUDO) $(STOW) --dir=$(CURDIR)/system --target=/ --restow --verbose=$(VERBOSITY) $(SYSTEM_PKGS)

restow: restow-config restow-system

# Delete helpers (remove symlinks created by stow)
delete-config:
	@echo "Deleting config packages: $(CONFIG_PKGS) from $(HOME_DIR)/.config"
	$(STOW) --dir=$(CURDIR)/.config --target=$(HOME_DIR)/.config --delete --verbose=$(VERBOSITY) $(CONFIG_PKGS)

delete-system:
	@echo "Deleting system packages: $(SYSTEM_PKGS) from /"
	$(SUDO) $(STOW) --dir=$(CURDIR)/system --target=/ --delete --verbose=$(VERBOSITY) $(SYSTEM_PKGS)

delete: delete-config delete-system

# Dry-run helpers (show what would happen)
dry-run-config:
	@echo "Dry-run stow config packages: $(CONFIG_PKGS) -> $(HOME_DIR)/.config"
	$(STOW) --dir=$(CURDIR)/.config --target=$(HOME_DIR)/.config --no --verbose=$(VERBOSITY) $(CONFIG_PKGS)

dry-run-system:
	@echo "Dry-run stow system packages: $(SYSTEM_PKGS) -> /"
	$(STOW) --dir=$(CURDIR)/system --target=/ --no --verbose=$(VERBOSITY) $(SYSTEM_PKGS)

dry-run: dry-run-config dry-run-system

# end of Makefile
