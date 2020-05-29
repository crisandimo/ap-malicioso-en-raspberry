#!/bin/sh
#    configuracion de un raspberry pi, instalacio y configuracion de ap + portal #    cautivo con exploit includo.
#    Copyright (C) 2013-2015 Viljo Viitanen <viljo.viitanen@iki.fi> and contributors
#

#primero una actualizacion de paquetes y librerias
apt-get update
apt-get upgrade -y

#habilitamos ssh para una conexion remota asegurada, inicio del servicio ssh
systemctl enable ssh
systemctl start ssh

#instalacion de hostapd
apt install hostapd || {
  echo "No se pudo instalar hostapd" 
  exit 1
}
#instalacion de dnsmasq habilitacion e inicio de servicio
apt install dnsmasq || {
  echo "No se pudo instalar dnsmasq" 
  exit 1
}
systemctl unmask hostapd
systemctl enable hostapd

sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent

#configuracion del archivo dhcp.conf para determinar el gateway determina ip fija
cat >> /etc/dhcpcd.conf << END
echo 1 > interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
END
#configuracion de forward en iptables 
cat >> /etc/sysctl.d/routed-ap.conf << END
echo 1 > net.ipv4.ip_forward=1
END

netfilter-persistent save
iptables-legacy-save

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

#determinamos el rano de dchp mascara ademas dle tiempo de consesion
cat >> /etc/dnsmasq.conf << END
echo 1 > interface=wlan0 # Listening interface
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h # Pool of IP addresses served via DHCP
domain=wlan     # Local wireless DNS domain
address=/gw.wlan/192.168.4.1  # Alias for this router
END

rfkill unblock wlan

#especificacion de los datos del SSID contraseña tipo canal entre otros.
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
