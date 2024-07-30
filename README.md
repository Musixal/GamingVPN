# What is GamingVPN?
A Lightweight VPN with Build-in Forward Error Correction Support(or A Network Improving Tool which works at VPN mode). Improves your Network Quality on a High-latency Lossy Link.
GamingVPN uses Forward Error Correction(Reed-Solomon code) to reduce packet loss rate, at the cost of additional bandwidth usage.

Assume your local network to your server is lossy. Just establish a VPN connection to your server with GamingVPN, access your server via this VPN connection, then your connection quality will be significantly improved. 
With well-tuned parameters , you can easily reduce IP or UDP/ICMP packet-loss-rate to less than 0.01% . Besides reducing packet-loss-rate, GamingVPN can also significantly improve your TCP latency and TCP single-thread download speed.
Optimized for gaming.

## How to Run

Run the following script on your server (debian/ubuntu supported):
```
bash <(curl -Ls --ipv4 https://github.com/Musixal/GamingVPN/raw/main/gamingvpn.sh)
```
# Usage
This project can be used both `directly` and in `reverse`. To use reverse on the `Iran server`, you must select `Configure for server` and click `Configure for client` on the `external server` and enter the `IP address of Iran`. 
So, in short, for direct use, the Iran server must be a client, and in case of reverse use, the external server becomes a client.
By default, the settings are optimized for gaming. You have to choose the amount of FEC carefully because it has a great effect on the bandwidth.
Its format is `FEC x:y`, which means send y redundant packets for every x packets. 
For example, `FEC 2:1` means that it sends one extra packet for every two packets, which increases bandwidth consumption by `1.5 times`.In the same way, FEC 2:2 doubles the bandwidth consumption. It is also possible to turn off FEC. In networks where there is no packet loss, it is not a problem to turn it off, but if there is high packet loss, it is better to set a value such as FEC 2:1 or FEC 2:4.

# Menu

![Menu](https://github.com/Musixal/GamingVPN/blob/main/menu/menu.png?raw=true)

# My Telegram channel
Check the channel below for more information:
https://t.me/Gozar_Xray

 # Support the project
 <a href="https://nowpayments.io/donation?api_key=6Z16MRY-AF14Y8T-J24TXVS-00RDKK7&source=lk_donation&medium=referral" target="_blank">
 <img src="https://nowpayments.io/images/embeds/donation-button-white.svg" alt="Crypto donation button by NOWPayments">
 </a>


# Source code
https://github.com/wangyu-/tinyfecVPN
