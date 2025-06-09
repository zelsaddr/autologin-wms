#!/bin/sh

# @author : github.com/zelsaddr
# for OpenWRT (set to rc.local for auto execute at startup)
# Check Log Message at system.log
# 
# Installation:
# 1. Install required packages:
#    opkg update
#    opkg install grep curl
#    opkg install bind-dig 
#
# 2. Make script executable:
#    chmod +x autowms.sh
#
# 3. For auto-start at boot, add to /etc/rc.local:
#    /path/to/autowms.sh &
#
# Requirements : 
#   - Latest grep (update via opkg install grep or via gui)
#   - sed
#   - curl
#   - dig

SETUSERNAME="maklogaming" # Your WMS-lite username
SETPASSWORD="MakloGaming312" # Your WMS-lite password
SETIFACE="wlan0" # Change with ur currently network interface, ex: wlan0, wlan1

# Connection check settings
PING_TIMEOUT=3
PING_COUNT=1
PING_TARGETS="1.1.1.1 8.8.8.8 9.9.9.9"
HTTP_CHECK_URL="http://www.google.com"

check_ping() {
    local success=0
    for target in $PING_TARGETS; do
        if ping -c $PING_COUNT -W $PING_TIMEOUT $target >/dev/null 2>&1; then
            success=1
            break
        fi
    done
    echo $success
}

check_dns() {
    if command -v dig >/dev/null 2>&1; then
        if dig +short +time=3 +tries=1 google.com >/dev/null 2>&1; then
            echo "1"
        else
            echo "0"
        fi
    else
        # If dig is not available, try using ping to check DNS
        if ping -c 1 -W 3 google.com >/dev/null 2>&1; then
            echo "1"
        else
            echo "0"
        fi
    fi
}

check_http() {
    if curl -s --connect-timeout 3 --max-time 5 $HTTP_CHECK_URL >/dev/null 2>&1; then
        echo "1"
    else
        echo "0"
    fi
}

check_connection() {
    local ping_result=$(check_ping)
    local dns_result=$(check_dns)
    local http_result=$(check_http)
    
    # Log detailed status
    # logger "[$(date)] Connection Check - Ping: $ping_result, DNS: $dns_result, HTTP: $http_result"
    
    # Consider connection down if any two checks fail
    if [ $ping_result -eq 0 ] && [ $dns_result -eq 0 ]; then
        logger "[$(date)] Tidak ada koneksi internet - Mencoba login"
        logger "[$(date)] $(do_logout)"
        sleep 1
        logger "[$(date)] $(do_login)"
        logger "[$(date)] Connection Check - Ping: $ping_result, DNS: $dns_result, HTTP: $http_result"
        echo "0"
    else
        echo "1"
    fi
}

generate_random_id(){
    echo $(echo $RANDOM | md5sum | head -c 4; echo;)
}

get_info() {
    getdata=$(curl -Ls -o /dev/null -w %{url_effective} 'http://8.8.8.8')
    echo "$getdata"
}

do_login() {
    url=$(get_info)
    gwid=$(echo $url | grep -oP 'gw_id=(.*?)\&' | sed 's/gw_id=//g' | sed 's/\&//g')
    mac=$(echo $url | grep -oP 'client_mac=(.*?)\&' | sed 's/client_mac=//g' | sed 's/\&//g')
    wlan=$(echo $url | grep -oP 'wlan=(.*?)\&' | sed 's/wlan=//g' | sed 's/\&//g')
    ipwan=$(ifconfig | grep -A 2 ''$SETIFACE'' | awk '/inet addr/{print substr($2,6)}')
    login=$(curl -s -H 'Host: welcome2.wifi.id' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'X-Requested-With: XMLHttpRequest' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.63 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Origin: http://welcome2.wifi.id' -H 'Referer: http://welcome2.wifi.id/wms/?gw_id='$gwid'&client_mac='$mac'&wlan='$wlan'' -H 'Accept-Language: en-US,en;q=0.9' --data-binary 'username_='$SETUSERNAME'&autologin_time=86000&username='$SETUSERNAME'.'$(generate_random_id)'%40wmslite..000&password='$SETPASSWORD'' 'http://welcome2.wifi.id/wms/auth/authnew/login/check_login.php?ipc='$ipwan'&gw_id='$gwid'&mac='$mac'&redirect=&wlan='$wlan'&landURL=')
    if echo "$login" | grep -q '"message":"Login Sukses"'; then
        echo "Sukses Login"
    else
        echo "Gagal Login"
    fi
}

do_logout() {
    logout=$(curl -s -H 'Host: welcome2.wifi.id' -H 'Content-Length: 0' -H 'Sec-Ch-Ua: \"-Not.A/Brand\";v=\"8\", \"Chromium\";v=\"102\"' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Sec-Ch-Ua-Mobile: ?0' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.63 Safari/537.36' -H 'Sec-Ch-Ua-Platform: \"Windows\"' -H 'Origin: https://logout.wifi.id' -H 'Sec-Fetch-Site: same-site' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Dest: empty' -H 'Referer: https://logout.wifi.id/' -H 'Accept-Language: en-US,en;q=0.9' --data-binary '0' 'https://welcome2.wifi.id/authnew/logout/logoutx.php')
    if echo "$logout" | grep -q 'Logout Berhasil'; then
        echo "Sukses Logout"
    else
        echo "Gagal Logout"
    fi
}

while true; do
    check_connection
    sleep 2  # Reduced sleep time for faster response
done
