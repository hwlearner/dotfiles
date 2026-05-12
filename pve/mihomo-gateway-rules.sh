#!/bin/sh
set -eu

TABLE_NAME="mihomo_gateway"
MARK="0x1"
ROUTE_TABLE="100"
IN_IFACE="${MIHOMO_GATEWAY_IFACE:-eth0}"

start() {
  ip rule show | grep -q "fwmark ${MARK} lookup ${ROUTE_TABLE}" || \
    ip rule add fwmark "${MARK}" table "${ROUTE_TABLE}"
  ip route replace local 0.0.0.0/0 dev lo table "${ROUTE_TABLE}"

  nft delete table inet "${TABLE_NAME}" 2>/dev/null || true
  nft -f - <<EOF
table inet ${TABLE_NAME} {
  chain dns_redirect {
    type nat hook prerouting priority dstnat; policy accept;
    iifname "${IN_IFACE}" udp dport 53 redirect to :5353
    iifname "${IN_IFACE}" tcp dport 53 redirect to :5353
  }

  chain proxy_prerouting {
    type filter hook prerouting priority mangle; policy accept;
    iifname "${IN_IFACE}" ip daddr 0.0.0.0/8 return
    iifname "${IN_IFACE}" ip daddr 10.0.0.0/8 return
    iifname "${IN_IFACE}" ip daddr 100.64.0.0/10 return
    iifname "${IN_IFACE}" ip daddr 127.0.0.0/8 return
    iifname "${IN_IFACE}" ip daddr 169.254.0.0/16 return
    iifname "${IN_IFACE}" ip daddr 172.16.0.0/12 return
    iifname "${IN_IFACE}" ip daddr 192.168.0.0/16 return
    iifname "${IN_IFACE}" ip daddr 224.0.0.0/4 return
    iifname "${IN_IFACE}" ip daddr 240.0.0.0/4 return
    iifname "${IN_IFACE}" tcp dport 53 return
    iifname "${IN_IFACE}" udp dport 53 return
    iifname "${IN_IFACE}" tcp dport 5353 return
    iifname "${IN_IFACE}" udp dport 5353 return
    iifname "${IN_IFACE}" meta l4proto tcp tproxy to :7891 meta mark set ${MARK} accept
    iifname "${IN_IFACE}" meta l4proto udp tproxy to :7891 meta mark set ${MARK} accept
  }
}
EOF
}

stop() {
  nft delete table inet "${TABLE_NAME}" 2>/dev/null || true
  while ip rule show | grep -q "fwmark ${MARK} lookup ${ROUTE_TABLE}"; do
    ip rule del fwmark "${MARK}" table "${ROUTE_TABLE}" 2>/dev/null || break
  done
  ip route flush table "${ROUTE_TABLE}" 2>/dev/null || true
}

case "${1:-start}" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  status)
    ip rule show
    ip route show table "${ROUTE_TABLE}" || true
    nft list table inet "${TABLE_NAME}" 2>/dev/null || true
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}" >&2
    exit 2
    ;;
esac
