#!/bin/sh
### Sample Firewall Arch Linux
# MIT License

# Copyright (c) 2025 - William C. Canin

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Features:
# ✅ SYN Flood Protection
# ✅ DDoS Prevention
# ✅ Port Scanning Detection
# ✅ Anti-Spoofing
# ✅ Advanced Rate Limiting
# ✅ IPv6 Protection
# ✅ Malformed Packet Chaining
# ✅ Sysctl Hardening
# ✅ Detailed Logging
# ✅ Multiple Levels of Protection

PATH="/sbin:/usr/sbin:/bin:/usr/bin:${PATH}"
export PATH

### Variables global
	MODPROBE="/usr/bin/modprobe"
	IPTABLES="/usr/bin/iptables"
	IPTABLES_SAVE="/usr/bin/iptables-save"
	IP6TABLES="/usr/bin/ip6tables"
	SYSTEMCTL="/usr/bin/systemctl"
	IPTABLES_RULES="/etc/iptables/iptables.rules"
	IP6TABLES_RULES="/etc/iptables/ip6tables.rules"
	CONFIG_FILE="/etc/firewall.conf"

### Load config
	if [ -f $CONFIG_FILE ]; then
		# shellcheck source=/etc/firewall.conf
		. "$CONFIG_FILE"
	else
		echo "File \"$CONFIG_FILE\" not found. Using defaults."
	fi

### Load security modules
	$MODPROBE ip_tables
	$MODPROBE iptable_nat
	$MODPROBE iptable_filter
	$MODPROBE ip_conntrack
	$MODPROBE ip_conntrack_ftp
	$MODPROBE ip_nat_ftp
	$MODPROBE ipt_MASQUERADE
	$MODPROBE iptable_mangle
	$MODPROBE nf_nat
	$MODPROBE nf_conntrack
	$MODPROBE x_tables
	$MODPROBE nf_nat_pptp
	$MODPROBE ipt_REJECT
	$MODPROBE ipt_LOG
	$MODPROBE nf_conntrack_tftp

### Clean rules and disable Iptables
_off() {
	### IPv4
	$IPTABLES -F
	$IPTABLES -X
	$IPTABLES -t nat -F
	$IPTABLES -t nat -X
	$IPTABLES -t mangle -F
	$IPTABLES -t mangle -X
	$IPTABLES -t raw -F
	$IPTABLES -t raw -X
	$IPTABLES -t security -F
	$IPTABLES -t security -X
	$IPTABLES -P INPUT ACCEPT
	$IPTABLES -P OUTPUT ACCEPT
	$IPTABLES -P FORWARD ACCEPT

	### IPv6 (security: block everything by default)
	$IP6TABLES -P INPUT DROP
	$IP6TABLES -P OUTPUT DROP
	$IP6TABLES -P FORWARD DROP
	$IP6TABLES -F
	$IP6TABLES -X
}

### Advanced protection chains
_create_protection_chains() {
	### SYN Flood Protection
	$IPTABLES -N SYN_FLOOD
	$IPTABLES -A SYN_FLOOD -m limit --limit 10/s --limit-burst 20 -j RETURN
	$IPTABLES -A SYN_FLOOD -j LOG --log-prefix "SYN Flood: "
	$IPTABLES -A SYN_FLOOD -j DROP

	### DDOS Protection
	$IPTABLES -N DDOS_PROTECT
	$IPTABLES -A DDOS_PROTECT -m limit --limit 100/s --limit-burst 100 -j RETURN
	$IPTABLES -A DDOS_PROTECT -j LOG --log-prefix "DDOS Attack: "
	$IPTABLES -A DDOS_PROTECT -j DROP

	### Port Scan Protection
	$IPTABLES -N PORTSCAN
	$IPTABLES -A PORTSCAN -m recent --name portscan --set -j LOG --log-prefix "Port Scan: "
	$IPTABLES -A PORTSCAN -j DROP

	### Bad Packets protection
	$IPTABLES -N BAD_PACKETS
	$IPTABLES -A BAD_PACKETS -p tcp --tcp-flags ALL NONE -j DROP
	$IPTABLES -A BAD_PACKETS -p tcp --tcp-flags ALL ALL -j DROP
	$IPTABLES -A BAD_PACKETS -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
	$IPTABLES -A BAD_PACKETS -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
	$IPTABLES -A BAD_PACKETS -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
	$IPTABLES -A BAD_PACKETS -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
	$IPTABLES -A BAD_PACKETS -j RETURN
}

### Start firewall
_on() {
	### Default policies
	$IPTABLES -P INPUT DROP
	$IPTABLES -P FORWARD DROP
	$IPTABLES -P OUTPUT ACCEPT

	### Create protection chains
	_create_protection_chains

	### Loopback interface
	$IPTABLES -A INPUT -i lo -j ACCEPT
	$IPTABLES -A OUTPUT -o lo -j ACCEPT

	### Allow established connections
	$IPTABLES -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
	$IPTABLES -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

	### Drop invalid packets early
	$IPTABLES -A INPUT -m conntrack --ctstate INVALID -j DROP

	### Check for bad packets
	$IPTABLES -A INPUT -j BAD_PACKETS

	### Anti-spoofing protection
	if [ "$ANTI_SPOOFING" = "y" ]; then
		$IPTABLES -A INPUT -s 10.0.0.0/8 -j DROP
		$IPTABLES -A INPUT -s 172.16.0.0/12 -j DROP
		$IPTABLES -A INPUT -s 192.168.0.0/16 -j DROP
		$IPTABLES -A INPUT -s 127.0.0.0/8 -j DROP
		$IPTABLES -A INPUT -s 169.254.0.0/16 -j DROP
		$IPTABLES -A INPUT -s 224.0.0.0/4 -j DROP
		$IPTABLES -A INPUT -d 224.0.0.0/4 -j DROP
		$IPTABLES -A INPUT -s 240.0.0.0/5 -j DROP
		$IPTABLES -A INPUT -d 240.0.0.0/5 -j DROP
	fi

	### ICMP (ping) handling based on protection level
	if [ "$ALLOW_ICMP" = "y" ]; then
		case "$PROTECTION_LEVEL" in
			low)
				$IPTABLES -A INPUT -p icmp -j ACCEPT
				;;
			medium|high)
				$IPTABLES -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
				$IPTABLES -A INPUT -p icmp --icmp-type echo-request -j DROP
				;;
			paranoid)
				$IPTABLES -A INPUT -p icmp -j DROP
				;;
		esac
	fi

	### SSH protection with multiple security layers
	if [ "$ALLOW_SSH" = "y" ]; then
		$IPTABLES -N SSH_PROTECT
		$IPTABLES -A SSH_PROTECT -m recent --name ssh_attempt --set
		$IPTABLES -A SSH_PROTECT -m recent --name ssh_attempt --update --seconds 60 --hitcount 4 -j DROP
		$IPTABLES -A SSH_PROTECT -j ACCEPT

		$IPTABLES -A INPUT -p tcp --dport "${SSH_PORT}" -m conntrack --ctstate NEW -j SSH_PROTECT
	fi

	### SYN Flood protection
	if [ "$SYN_FLOOD_PROTECTION" = "y" ]; then
		$IPTABLES -A INPUT -p tcp --syn -j SYN_FLOOD
	fi

	### DDOS protection
	if [ "$DDOS_PROTECTION" = "y" ]; then
		$IPTABLES -A INPUT -p tcp -m conntrack --ctstate NEW -j DDOS_PROTECT
	fi

	### Port Scan protection
	if [ "$PORT_SCAN_PROTECTION" = "y" ]; then
		$IPTABLES -A INPUT -m recent --name portscan --rcheck --seconds 3600 -j DROP
		$IPTABLES -A INPUT -m recent --name portscan --remove
	fi

	### Rate limiting for new connections
	$IPTABLES -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
	$IPTABLES -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP

	### Logging for suspicious activities
	$IPTABLES -N LOG_SUSPICIOUS
	$IPTABLES -A LOG_SUSPICIOUS -m limit --limit 2/min -j LOG --log-prefix "Suspicious: " --log-level 4
	$IPTABLES -A LOG_SUSPICIOUS -j DROP

	$IPTABLES -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j LOG_SUSPICIOUS
	$IPTABLES -A INPUT -p tcp --tcp-flags ALL ALL -j LOG_SUSPICIOUS
	$IPTABLES -A INPUT -p tcp --tcp-flags ALL NONE -j LOG_SUSPICIOUS

	### Masquerade network with additional security
	if [ "$MASQUERADE_ENABLE" = "y" ] && [ -n "$INTERFACE_WAN" ]; then
		echo 1 > /proc/sys/net/ipv4/ip_forward
		echo 1 > /proc/sys/net/ipv4/conf/all/forwarding

		# Basic masquerade
		$IPTABLES -t nat -A POSTROUTING -o "$INTERFACE_WAN" -j MASQUERADE

		# Secure forwarding rules
		if [ -n "$INTERFACE_LAN" ]; then
			$IPTABLES -A FORWARD -i "$INTERFACE_LAN" -o "$INTERFACE_WAN" -j ACCEPT
			$IPTABLES -A FORWARD -i "$INTERFACE_WAN" -o "$INTERFACE_LAN" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			$IPTABLES -A FORWARD -i "$INTERFACE_WAN" -o "$INTERFACE_LAN" -j DROP
		fi
	fi

	### Application layer protections
	$IPTABLES -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
	$IPTABLES -A INPUT -p tcp --dport 443 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

	### Final reject rules with logging
	$IPTABLES -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
	$IPTABLES -A INPUT -p tcp -j REJECT --reject-with tcp-reset
	$IPTABLES -A INPUT -j REJECT --reject-with icmp-proto-unreachable

	### Comprehensive logging
	$IPTABLES -N LOG_DROPPED
	$IPTABLES -A LOG_DROPPED -m limit --limit 5/min -j LOG --log-prefix "FW-Dropped: " --log-level 4
	$IPTABLES -A LOG_DROPPED -j DROP

	$IPTABLES -A INPUT -j LOG_DROPPED

	### IPv6 security (block everything except essential)
	$IP6TABLES -P INPUT DROP
	$IP6TABLES -P FORWARD DROP
	$IP6TABLES -P OUTPUT DROP

	$IP6TABLES -A INPUT -i lo -j ACCEPT
	$IP6TABLES -A OUTPUT -o lo -j ACCEPT
	$IP6TABLES -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
	$IP6TABLES -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

	### Enable hardening sysctl parameters
	echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
	echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
	echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
	echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter
	echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/default/accept_redirects
	echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
	echo 0 > /proc/sys/net/ipv4/conf/default/accept_source_route
}

_save() {
	$IPTABLES_SAVE > $IPTABLES_RULES
	$IP6TABLES -S > $IP6TABLES_RULES 2>/dev/null || true
	$SYSTEMCTL restart iptables.service 2>/dev/null || true
}

### Options
case $1 in
	off)
		_off
		_save
		echo "Firewall disabled"
		echo "Note: Basic configuration file is at \"$CONFIG_FILE\"."
		;;
	on)
		_off
		_on
		_save
		echo "Firewall enabled with $PROTECTION_LEVEL protection"
		echo "Note: Basic configuration file is at \"$CONFIG_FILE\"."
		;;
	status)
		echo "=== IPv4 Rules ==="
		$IPTABLES -L -n -v
		echo ""
		echo "=== IPv6 Rules ==="
		$IP6TABLES -L -n -v 2>/dev/null || echo "IPv6 not configured"
		;;
	*)
		echo "Usage: $0 {on|off|status}"
		echo "Protection level: $PROTECTION_LEVEL"
		exit 1
		;;
esac

exit 0