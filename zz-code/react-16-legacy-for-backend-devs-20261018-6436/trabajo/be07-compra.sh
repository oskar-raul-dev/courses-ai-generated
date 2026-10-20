#!/usr/bin/env bash
# be07: la compra de punta a punta contra el mock de Google Play (3002, en r16t7-app) y el binario del 3011.
# Una con tarjeta (confirmada al instante) y otra en efectivo (pendiente PLAY_PENDING_MS = 3 s), cada una avisada
# por el juego y por la notificación, y la notificación dos veces. Uso: trabajo/be07-compra.sh [--sin-reiniciar]
Z="$(cd "$(dirname "$0")/.." && pwd)"
[ "${1:-}" = --sin-reiniciar ] || "$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1
SUF=$(date +%s)
"$Z/trabajo/tools.sh" "
B=http://r16t7-go:3011; P=http://app:3002; S=$SUF
echo '== la tienda: una con tarjeta y otra en efectivo'
curl -s -X POST -H 'Content-Type: application/json' -d \"{\\\"purchaseToken\\\":\\\"tok-card-\$S\\\",\\\"method\\\":\\\"card\\\"}\" \$P/purchases; echo
curl -s -X POST -H 'Content-Type: application/json' -d \"{\\\"purchaseToken\\\":\\\"tok-efecty-\$S\\\",\\\"method\\\":\\\"cash\\\"}\" \$P/purchases; echo
for T in card efecty; do
  echo \"== el juego avisa la de \$T, dos veces\"
  for i in 1 2; do curl -s -w ' → %{http_code}\n' -X POST -H 'Content-Type: application/json' \
    -d \"{\\\"purchaseToken\\\":\\\"tok-\$T-\$S\\\",\\\"productId\\\":\\\"spins-10\\\"}\" \$B/players/43/purchases; done
done
sleep 3.5
for T in card efecty; do
  echo \"== Google Play notifica la de \$T, y la notificación llega dos veces\"
  curl -s -o /dev/null -X POST -H 'Content-Type: application/json' -d \"{\\\"purchaseToken\\\":\\\"tok-\$T-\$S\\\"}\" \$P/notifications
  curl -s -o /dev/null -X POST -H 'Content-Type: application/json' -d \"{\\\"purchaseToken\\\":\\\"tok-\$T-\$S\\\"}\" \$P/notifications
  curl -s \$P/notifications/tok-\$T-\$S | jq -c '.[]' | while read -r EV; do
    curl -s -w ' → %{http_code}\n' -X POST -H 'Content-Type: application/json' -d \"\$EV\" \$B/purchases/notifications
  done
done"
echo "== la base"
docker exec r16t7-pg psql -U esclusa -d esclusa -Atc "SELECT purchase_token, player_id, count(*) FROM purchases WHERE purchase_token LIKE '%-$SUF' GROUP BY 1,2 ORDER BY 1"
docker exec r16t7-pg psql -U esclusa -d esclusa -Atc "SELECT 'giros pagos de María R.: ' || paid_spins FROM players WHERE id = 43"
