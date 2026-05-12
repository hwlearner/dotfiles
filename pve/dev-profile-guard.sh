#!/bin/sh

for file in /root/.profile /root/.bashrc; do
  [ -f "$file" ] || continue
  cp -a "$file" "$file.bak.$(date +%Y%m%d%H%M%S)"
  sed -i 's#^\. "$HOME/.cargo/env"#[ -f "$HOME/.cargo/env" ] \&\& . "$HOME/.cargo/env"#' "$file"
done
