#!/bin/bash

set -euo pipefail
 
### =========================

### CONFIG

### =========================

LAN_BRIDGE="vmbr999"

LAN_IP_CIDR="192.168.100.1/24"

LAN_IP="192.168.100.1"

LAN_NET="192.168.100.0/24"

DHCP_RANGE_START="192.168.100.50"

DHCP_RANGE_END="192.168.100.200"

WAN_BRIDGE="vmbr0"
 
INTERFACES_FILE="/etc/network/interfaces"

DNSMASQ_CONF="/etc/dnsmasq.d/${LAN_BRIDGE}.conf"
 
echo "=== Proxmox VE 9: Host NAT + DHCP setup (${LAN_BRIDGE}) ==="
 
### =========================

### 1. Create internal bridge (idempotent)

### =========================

echo "[1/7] Ensuring ${LAN_BRIDGE} exists..."
 
if ! grep -q "iface ${LAN_BRIDGE} inet" "${INTERFACES_FILE}"; then

cat >> "${INTERFACES_FILE}" <<EOF
 
auto ${LAN_BRIDGE}

iface ${LAN_BRIDGE} inet static

    address ${LAN_IP_CIDR}

    bridge-ports none

    bridge-stp off

    bridge-fd 0

EOF

fi
 
if ! ip link show "${LAN_BRIDGE}" >/dev/null 2>&1; then

    ifup "${LAN_BRIDGE}"

fi
 
### =========================

### 2. Enable IPv4 forwarding (runtime + persistent)

### =========================

echo "[2/7] Enabling IPv4 forwarding..."
 
sysctl -w net.ipv4.ip_forward=1 >/dev/null
 
if grep -q "^net.ipv4.ip_forward" /etc/sysctl.conf; then

    sed -i 's/^net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf

else

    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

fi
 
### =========================

### 3. Install required packages

### =========================

echo "[3/7] Installing dnsmasq + iptables-persistent..."
 
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq

apt-get install -y dnsmasq iptables-persistent >/dev/null
 
### =========================

### 4. Configure dnsmasq (DHCP only)

### =========================

echo "[4/7] Configuring dnsmasq for ${LAN_BRIDGE}..."
 
cat > "${DNSMASQ_CONF}" <<EOF

interface=${LAN_BRIDGE}

bind-interfaces

except-interface=lo

no-hosts

no-resolv
 
dhcp-range=${DHCP_RANGE_START},${DHCP_RANGE_END},12h

dhcp-option=option:router,${LAN_IP}

dhcp-option=option:dns-server,1.1.1.1,8.8.8.8

EOF
 
dnsmasq --test >/dev/null
 
systemctl restart dnsmasq

systemctl enable dnsmasq >/dev/null
 
### =========================

### 5. Apply NAT + forwarding rules (idempotent)

### =========================

echo "[5/7] Applying NAT + forwarding rules..."
 
# NAT

iptables -t nat -C POSTROUTING -s "${LAN_NET}" -o "${WAN_BRIDGE}" -j MASQUERADE 2>/dev/null || \

iptables -t nat -A POSTROUTING -s "${LAN_NET}" -o "${WAN_BRIDGE}" -j MASQUERADE
 
# Forward out

iptables -C FORWARD -s "${LAN_NET}" -o "${WAN_BRIDGE}" -j ACCEPT 2>/dev/null || \

iptables -A FORWARD -s "${LAN_NET}" -o "${WAN_BRIDGE}" -j ACCEPT
 
# Forward return

iptables -C FORWARD -d "${LAN_NET}" -i "${WAN_BRIDGE}" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \

iptables -A FORWARD -d "${LAN_NET}" -i "${WAN_BRIDGE}" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
 
### =========================

### 6. Persist firewall rules

### =========================

echo "[6/7] Saving firewall rules..."
 
iptables-save > /etc/iptables/rules.v4
 
### =========================

### 7. Verification

### =========================

echo "[7/7] Verification summary:"

ip -4 addr show "${LAN_BRIDGE}" | grep inet

systemctl is-active dnsmasq

iptables -t nat -L POSTROUTING -n -v | grep MASQUERADE
 
echo "=== SUCCESS ==="

echo "Bridge      : ${LAN_BRIDGE}"

echo "Gateway IP  : ${LAN_IP}"

echo "DHCP Range  : ${DHCP_RANGE_START} - ${DHCP_RANGE_END}"

echo "Attach VMs  : ${LAN_BRIDGE} (DHCP auto-assign)"
