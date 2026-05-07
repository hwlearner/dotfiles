#!/bin/bash
# Cleanup pi-coding-agent and all its files
# Run this from your terminal (not sandboxed)

set -e

echo "=== Uninstalling pi-coding-agent Homebrew formula ==="
brew uninstall pi-coding-agent

echo ""
echo "=== Removing global npm pi packages ==="
npm uninstall -g \
  @demigodmode/pi-web-agent \
  @eko24ive/pi-ask \
  @mjakl/pi-subagent \
  @sherif-fanous/pi-catppuccin \
  @tungthedev/pi-extensions \
  @weiping/pi-superpowers \
  pi-docparser \
  pi-markdown-preview \
  pi-show-diffs \
  pi-zentui

echo ""
echo "=== Removing ~/.pi directory ==="
rm -rf ~/.pi

echo ""
echo "=== Verification ==="
brew list --formula 2>/dev/null | grep pi-coding-agent && echo "WARN: pi-coding-agent still installed" || echo "OK: pi-coding-agent uninstalled"
npm list -g --depth=0 2>/dev/null | grep -i pi && echo "WARN: pi npm packages remain" || echo "OK: no pi npm packages"
test -d ~/.pi && echo "WARN: ~/.pi still exists" || echo "OK: ~/.pi deleted"

echo ""
echo "Done. All pi-coding-agent traces removed."
