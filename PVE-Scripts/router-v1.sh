#!/bin/bash
set -e
 
### CONFIG ###
LAN_BRIDGE="vmbr999"
LAN_IP="192.168.100.1/24"
LAN_NET="192.168.100.0/24"
DHCP_RANGE_START="192.168.100.50"
DHCP_RANGE_END="192.168.100.200"
WAN_BRIDGE="vmbr0"
 
echo "=== Proxmox Host NAT + DHCP Setup ($LAN_BRIDGE) ==="
 
### 1. Create internal bridge ###
echo "[1/7] Configuring $LAN_BRIDGE..."
 
if ! grep -q "iface $LAN_BRIDGE" /etc/network/interfaces; then
cat >> /etc/network/interfaces <<EOF
 
auto $LAN_BRIDGE
iface $LAN_BRIDGE inet static
    address $LAN_IP
    bridge-ports none
    bridge-stp off
    bridge-fd 0
EOF
fi
 
ifreload -a
 
### 2. Enable IPv4 forwarding ###
echo "[2/7] Enabling IPv4 forwarding..."
 
echo 1 > /proc/sys/net/ipv4/ip_forward
 
if grep -q "net.ipv4.ip_forward" /etc/sysctl.conf; then
    sed -i 's/^#\?net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
else
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
 
sysctl -p >/dev/null
 
### 3. Install required packages ###
echo "[3/7] Installing dnsmasq + iptables-persistent..."
 
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y dnsmasq iptables-persistent >/dev/null
 
### 4. Configure dnsmasq (DHCP only on vmbr999) ###
echo "[4/7] Configuring DHCP (dnsmasq)..."
 
cat > /etc/dnsmasq.d/$LAN_BRIDGE.conf <<EOF
interface=$LAN_BRIDGE
bind-interfaces
dhcp-range=$DHCP_RANGE_START,$DHCP_RANGE_END,12h
dhcp-option=option:router,192.168.100.1
dhcp-option=option:dns-server,1.1.1.1,8.8.8.8
EOF
 
systemctl restart dnsmasq
systemctl enable dnsmasq
 
### 5. Apply NAT + forwarding rules ###
echo "[5/7] Applying NAT rules..."
 
iptables -t nat -C POSTROUTING -s $LAN_NET -o $WAN_BRIDGE -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -s $LAN_NET -o $WAN_BRIDGE -j MASQUERADE
 
iptables -C FORWARD -s $LAN_NET -o $WAN_BRIDGE -j ACCEPT 2>/dev/null || \
iptables -A FORWARD -s $LAN_NET -o $WAN_BRIDGE -j ACCEPT
 
iptables -C FORWARD -d $LAN_NET -i $WAN_BRIDGE -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
iptables -A FORWARD -d $LAN_NET -i $WAN_BRIDGE -m state --state ESTABLISHED,RELATED -j ACCEPT
 
### 6. Persist firewall rules ###
echo "[6/7] Saving firewall rules..."
 
iptables-save > /etc/iptables/rules.v4
 
### 7. Verification ###
echo "[7/7] Verification summary:"
ip a show $LAN_BRIDGE | grep inet
systemctl status dnsmasq --no-pager | grep Active
iptables -t nat -L POSTROUTING -n -v | grep MASQUERADE
 
echo "=== SUCCESS ==="
echo "Bridge        : $LAN_BRIDGE"
echo "Gateway IP    : 192.168.100.1"
echo "DHCP Range    : $DHCP_RANGE_START - $DHCP_RANGE_END"
echo "Attach VMs to : $LAN_BRIDGE (DHCP will auto-work)"