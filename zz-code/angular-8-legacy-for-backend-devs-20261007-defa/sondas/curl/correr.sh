#!/bin/sh
# Runs, as written, the curl commands of incident 07 and 22 solutions (extracted to cmd07.sh / cmd22.sh).
cd /w && node armar-db.js
(/a8/node_modules/.bin/json-server --quiet --port 3000 /tmp/db.json >/dev/null 2>&1 &)
i=0; until curl -s http://localhost:3000/samples >/dev/null; do i=$((i+1)); [ $i -gt 30 ] && break; sleep 1; done
echo "-- 07: bordes en Z antes del parche:"; curl -s http://localhost:3000/referenceRanges | grep -c '[0-9]Z"'
sh cmd07.sh >/dev/null
echo "-- 07: bordes en Z despues del parche:"; curl -s http://localhost:3000/referenceRanges | grep -c '[0-9]Z"'
curl -s "http://localhost:3000/referenceRanges?analyte=potassium" | node -e 'let b="";process.stdin.on("data",c=>b+=c).on("end",()=>JSON.parse(b).forEach(r=>console.log("   v"+r.version, r.effectiveFrom, r.effectiveTo)))'
echo "-- 22: la consulta del cuaderno:"; curl -s "http://localhost:3000/samples?id=7202&id=7210" | node -e 'let b="";process.stdin.on("data",c=>b+=c).on("end",()=>JSON.parse(b).forEach(s=>console.log("  ",s.id,s.collectedBy,s.collectedAt,s.receivedBy,s.receivedAt)))'
sh cmd22.sh >/dev/null
echo "-- 22: la nota:"; curl -s http://localhost:3000/samples/7202 | node -e 'let b="";process.stdin.on("data",c=>b+=c).on("end",()=>{const s=JSON.parse(b);console.log("  ",s.collectedAt,"|",s.custodyNote)})'
