cat >> /etc/sysctl.d/routed-ap.conf << END
echo 1 > net.ipv4.ip_forward=1
END

netfilter-persistent save
iptables-legacy-save

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig

#determinamos el rango del dchp,mascara y le tiempo de consesion
cat >> /etc/dnsmasq.conf << END
#definicion de la interfaz por la que se dispersara el dhcp
echo 1 > interface=wlan0 # Listening interface
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h # Pool of IP addresses served via DHCP
domain=wlan     # Local wireless DNS domain
address=/gw.wlan/192.168.4.1  # Alias for this router
END

#configuracion del portal cautivo
cat >> /etc/nodogsplash.conf << END
GatewayInterface wlan0
Gatewayadderss 192.168.4.1
MaxClients 250
AuthidleTimeout 480
#Relacion de regla en el firewall apertura de puertos 
FirewallRuleSet users-to-router {
FirewallRule allow udp port 53
FirewallRule allow tcp port 53
FirewallRule allow udp port 67
FirewallRule allow tcp port 22
FirewallRule allow tcp port 80
FirewallRule allow tcp port 443
END

#tasladamos el portal cautivo a la carpeta de configuracion de nodogsplash
mv /pi/home/splash.html /etc/nodogsplash
mv /pi/home/login_movil.html /etc/nodogsplash

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
