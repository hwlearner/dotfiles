# Router LXC 100 / Mihomo Transparent Gateway

This directory mirrors the current router LXC runtime configuration in sanitized form.

- PVE CTID: `100`
- Hostname: `router`
- IP: `192.168.1.20/24`
- OS: Debian 12 bookworm
- Runtime config path: `/etc/mihomo/config.yaml`
- Mihomo service: `/etc/systemd/system/mihomo.service`
- Gateway service: `/etc/systemd/system/mihomo-gateway.service`
- Gateway rules script: `/usr/local/sbin/mihomo-gateway-rules.sh`

Sensitive values are intentionally replaced with `<REDACTED>`:

- Mihomo `secret`
- subscription URL token/path
- any token/password-looking fields

Do not deploy this directory verbatim without restoring secrets from the runtime secret source.
