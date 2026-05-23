#!/bin/bash
#=============================================================================
# WiFi Optimization Script for HG680P (RTL8723BS)
# This script configures WiFi for maximum throughput on the HG680P STB
# Target: 50+ Mbps on 2.4GHz with HT40 mode
#=============================================================================

# Configure WiFi interface for optimal performance
configure_wifi() {
    # Wait for WiFi module to load
    sleep 3

    # Load RTL8723BS module if not loaded
    if ! lsmod | grep -q r8723bs; then
        modprobe r8723bs
        sleep 2
    fi

    # Check if wireless device exists
    if ! iw dev | grep -q "Interface"; then
        echo "WiFi interface not found, skipping configuration"
        return 1
    fi

    # Get the wireless interface name
    WIFI_IFACE=$(iw dev | grep "Interface" | awk '{print $2}' | head -1)

    if [ -z "$WIFI_IFACE" ]; then
        echo "No WiFi interface detected"
        return 1
    fi

    echo "Configuring WiFi interface: $WIFI_IFACE"

    # Configure UCI wireless settings for maximum performance
    uci batch <<-EOF
        set wireless.radio0=wifi-device
        set wireless.radio0.type='mac80211'
        set wireless.radio0.channel='6'
        set wireless.radio0.htmode='HT40'
        set wireless.radio0.band='2g'
        set wireless.radio0.disabled='0'
        set wireless.radio0.country='ID'
        set wireless.radio0.txpower='20'
        set wireless.radio0.cell_density='0'
        set wireless.radio0.distance='50'

        set wireless.default_radio0=wifi-iface
        set wireless.default_radio0.device='radio0'
        set wireless.default_radio0.network='lan'
        set wireless.default_radio0.mode='ap'
        set wireless.default_radio0.ssid='HG680P-OpenWrt'
        set wireless.default_radio0.encryption='psk2'
        set wireless.default_radio0.key='12345678'
        set wireless.default_radio0.ieee80211w='0'
        set wireless.default_radio0.wpa_group_rekey='0'
        set wireless.default_radio0.disassoc_low_ack='0'
        set wireless.default_radio0.max_inactivity='3600'
        commit wireless
EOF

    # Apply wireless configuration
    wifi reload

    echo "WiFi configured successfully with HT40 mode for optimal throughput"
}

# Optimize kernel parameters for WiFi performance
optimize_kernel_params() {
    # Increase network buffer sizes for better throughput
    sysctl -w net.core.rmem_max=16777216 2>/dev/null
    sysctl -w net.core.wmem_max=16777216 2>/dev/null
    sysctl -w net.core.rmem_default=1048576 2>/dev/null
    sysctl -w net.core.wmem_default=1048576 2>/dev/null
    sysctl -w net.core.netdev_max_backlog=5000 2>/dev/null
    sysctl -w net.ipv4.tcp_rmem='4096 1048576 16777216' 2>/dev/null
    sysctl -w net.ipv4.tcp_wmem='4096 1048576 16777216' 2>/dev/null
    sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null
    sysctl -w net.ipv4.tcp_mtu_probing=1 2>/dev/null

    # Persist settings
    cat >> /etc/sysctl.conf <<-EOF

# WiFi Performance Optimization for HG680P
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.rmem_default=1048576
net.core.wmem_default=1048576
net.core.netdev_max_backlog=5000
net.ipv4.tcp_rmem=4096 1048576 16777216
net.ipv4.tcp_wmem=4096 1048576 16777216
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_mtu_probing=1
EOF

    echo "Kernel network parameters optimized for WiFi throughput"
}

# Main execution
echo "=== HG680P WiFi Optimization Script ==="
echo "Target: 50+ Mbps throughput with RTL8723BS"
configure_wifi
optimize_kernel_params
echo "=== Optimization Complete ==="