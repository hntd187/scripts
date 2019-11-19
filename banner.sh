#!/bin/bash
zip=$(curl -s ipinfo.io/postal)

echo ""
echo "Hostname" | toilet -t  -F border --gay --font mono9
echo " Date: $(date)"
echo " Uptime: $(uptime)"
echo ""
echo " Weather for: $zip"
ansiweather -a false -s true -u imperial -l "$(curl -s ipinfo.io | jq -rM '"\(.city),\(.country)"')"
echo ""
