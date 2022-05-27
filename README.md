# openwrt-ASUSddns-script
ASUSddns extension for openwrt ddns
## Requirement
A working ASUS router to extract the MAC and WPS pin code

MAC: `nvram get et0macaddr`\
WPS pin: `nvram get secret_code`

On the openwrt ddns configuration page

Username=MAC\
Password=WPS pin

## Credits
https://github.com/BigNerd95/ASUSddns
