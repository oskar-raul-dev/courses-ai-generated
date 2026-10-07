# rescatado de la sesión 14cfaf06, 2026-09-12T02:13:49Z · Verify naming convention and completeness
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== ¿existe algún beaNN- (sin guion) en el repo? ==="
ls */ | grep -E '^bea[0-9]' || echo "NINGUNO"
echo "=== ¿quedan be-a-NN- ? ==="
grep -rl 'be-a-[0-9]' --include='*.md' . || echo "NINGUNO"
echo "=== referencias a 'bea' en prompts de react16 (muestra) ==="
grep -rho 'bea[-0-9][0-9-]*' react-16-legacy-for-backend-devs/prompts/ | sort | uniq -c | sort -rn | head
echo "=== angular-8 prompts: cómo nombra sus apéndices ==="
grep -rho 'bea[-0-9][0-9-]*' angular-8-legacy-for-backend-devs/prompts/ | sort | uniq -c | sort -rn | head -5
echo "=== cabeza de bea-06 (react16) ==="
head -20 react-16-legacy-for-backend-devs/bea-06-tiempo-zonas-y-relojes.md
echo "=== cola de be07 ==="
tail -12 react-16-legacy-for-backend-devs/be07-liquidacion-dinero-entero-y-transaccional.md
