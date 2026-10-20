#!/usr/bin/env bash
# T5: estado HTTP final (siguiendo redirecciones) y URL de destino de cada enlace nuevo de a6 y a7.
docker run --rm --label curso=vue2-legacy --label tanda=T5 -v "$PWD/salidas:/s" node:14.21.3 bash -c '
while read u; do
  r=$(curl -s -o /dev/null -L --max-time 20 -A "Mozilla/5.0" -w "%{http_code} %{url_effective}" "$u")
  echo "$r  <-  $u"
done < /s/t5-urls.txt'
