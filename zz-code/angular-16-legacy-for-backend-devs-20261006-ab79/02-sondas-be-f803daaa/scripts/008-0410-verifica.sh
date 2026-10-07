# rescatado de la sesión f803daaa, 2026-09-09T04:10:56Z · Check maven temurin 8 image architectures
curl -s --max-time 15 "https://hub.docker.com/v2/repositories/library/maven/tags/3.8-eclipse-temurin-8/" | python3 -c "
import sys,json; d=json.load(sys.stdin)
print('maven:3.8-eclipse-temurin-8 ->', sorted({i['architecture'] for i in d.get('images',[]) if i.get('status')=='active'}))" 2>/dev/null || echo "tag no encontrado"
