#!/bin/sh
c=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 25 -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/126 Safari/537.36" "$1")
echo "$c $1"
