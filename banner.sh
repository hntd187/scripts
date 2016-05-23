#!/bin/bash
zip=$(curl -s ipinfo.io/postal)

echo ""
echo -e "\$$(hostname)$" | toilet -t  -F border --gay --font mono12
echo -e "  Date: $(date)" | toilet -t --gay --font term
echo -e "  Uptime: $(uptime -p)" | toilet -t --gay --font term
echo ""
echo "  Weather for: $zip" | toilet -t --gay --font term
weather -q 18944 | awk '{print " ",$0}' | toilet -t --gay --font term
echo ""
