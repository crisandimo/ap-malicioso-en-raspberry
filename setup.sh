#!/bin/sh
#    configuracion de un raspberry pi, instalacio y configuracion de ap + portal cautivo con exploit includo.
#    Copyright (C) 2013-2015 Viljo Viitanen <viljo.viitanen@iki.fi> and contributors
#

apt-get update
apt-get upgrade -y
systemctl enable ssh
systemctl start ssh
apt install hostapd || {
  echo "No se pudo instalar hostapd" 
  exit 1
}
apt install dnsmasq || {
  echo "No se pudo instalar dnsmasq" 
  exit 1
}
systemctl unmask hostapd
systemctl enable hostapd

sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

cat >> /etc/dhcpcd.conf << END
echo 1 > interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
END

cat >> /etc/sysctl.d/routed-ap.conf << END
echo 1 > net.ipv4.ip_forward=1
END

netfilter-persistent save
iptables-legacy-save

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

cat >> /etc/dnsmasq.conf << END
echo 1 > interface=wlan0 # Listening interface
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h # Pool of IP addresses served via DHCP
domain=wlan     # Local wireless DNS domain
address=/gw.wlan/192.168.4.1  # Alias for this router
END

rfkill unblock wlan

cat >> /etc/hostapd/hostapd.conf << END
echo 1 > country_code=CO
interface=wlan0
ssid=Zona Wifi Claro
hw_mode=g
channel=7
auth_algs=1
wmm_enabled=0
END

systemctl reboot