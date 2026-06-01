# Packages

`packages.txt` — user-installed apt packages for Debian/WSL.

```bash
sudo apt install $(grep -v '^#' packages/packages.txt | xargs)
```

Docker, Terraform, and Node.js require custom repos — handled by `install_packages_debian.sh`.

To regenerate from current system (for reference only):
```bash
apt-mark showmanual | sort
```
