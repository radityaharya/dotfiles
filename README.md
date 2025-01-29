# dotfiles

this repository contains my personal dotfiles.

```bash
curl -sL dot.radityaharya.com | bash
```

## Prerequisites

- Ubuntu/Debian-based system
- `git`
- `ansible` (will be installed automatically if missing)

- Environment variables:
  - `TAILSCALE_KEY` (will be used to authenticate tailscale, skipped if not set)

## Backup

during installation, existing configurations will be automatically backed up. logs can be found at `~/dotfiles_backup_<timestamp>/`.