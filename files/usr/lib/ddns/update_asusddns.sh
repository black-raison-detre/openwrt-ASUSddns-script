# Thanks ASUSddns script by BigNerd95 (https://github.com/BigNerd95/ASUSddns)
# username is asus router's macaddr
# password is asus router's wps code
[ -z "$domain" ] && write_log 14 "Service section not configured correctly! Missing 'domain'"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username(macaddr)'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password(wps code)'"

strip_dots_colons(){
	echo $(echo "$1" | tr -d .:)
}

calculate_password(){
	local host="${domain}.asuscomm.com"
	local wanIP=$__IP
	local key=$password
	local stripped_host=$(strip_dots_colons $host)
	local stripped_wanIP=$(strip_dots_colons $wanIP)
	echo $(echo -n "$stripped_host$stripped_wanIP" | openssl md5 -hmac "$key" 2>/dev/null | cut -d ' ' -f 2 | tr 'a-z' 'A-Z')
}

asus_request(){
	local user=$(strip_dots_colons $username)
	local password=$(calculate_password)
	local host="${domain}.asuscomm.com"
	local wanIP=$__IP
	case $1 in
		"register")
			local path="ddns/register.jsp"
		;;
		"update")
			local path="ddns/update.jsp"
		;;
	esac
	echo $(curl --write-out %{http_code} --silent --output /dev/null --user-agent "ez-update-3.0.11b5 unknown [] (by Angus Mackay)" --basic --user $user:$password "http://ns1.asuscomm.com/$path?hostname=$host&myip=$wanIP")
}

is_dns_registered(){
	local host="${domain}.asuscomm.com"
    local dns_resolution=$(nslookup $host ns1.asuscomm.com 2>/dev/null)
	for token in $dns_resolution; do
		if [ $token = "NXDOMAIN" ]; then
			return 0 # not registered
		fi
	done
	return 1 # registered
}

code_to_string(){
	case $1 in
		"register")
			local log_mode="Registration"
		;;
		"update")
			local log_mode="Update"
		;;
	esac
	case $2 in
		200 )
			write_log 7 "$log_mode success."
		;;
		203 | 233 )
			write_log 7 "$log_mode failed."
		;;
		220 )
			write_log 7 "$log_mode same domain success."
		;;
		230 )
			write_log 7 "$log_mode new domain success."
		;;
		297 )
			write_log 7 "Invalid hostname."
		;;
        298 )
			write_log 7 "Invalid domain name."
		;;
		299 )
			write_log 7 "Invalid IP format."
		;;
		401 )
			write_log 7 "Authentication failure."
		;;
		407 )
			write_log 7 "Proxy authentication Required."
		;;
		* )
			write_log 7 "Unknown result code. ($1)"
		;;
	esac
}

if [ -n "$__IP" ]; then
	if is_dns_registered; then
		local return_code=$(asus_request update)
		code_to_string update $return_code
	else
		local return_code=$(asus_request register)
		code_to_string register $return_code
	fi
else
	write_log 14 "Connection issue. No WAN IP"
fi