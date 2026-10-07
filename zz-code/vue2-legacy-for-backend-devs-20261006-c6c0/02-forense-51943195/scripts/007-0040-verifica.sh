# rescatado de la sesión 51943195, 2026-09-10T00:40:40Z · Spot-check symptom sourcing in course 02
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
echo "--F4 NumberInt--"; grep -n "NumberInt\|double" 04-el-esquema-que-no-esta-en-la-base.md | head -4
echo "--F5 unwind preserve--"; grep -n "preserveNullAndEmptyArrays" 05-lookup-y-por-que-es-una-alarma.md | head -3
echo "--F6 matchedCount--"; grep -n "matchedCount" 06-atomicidad-transacciones-consistencia.md | head -3
echo "--F10 envelope/curl--"; grep -n "envelope\|_id" 10-express-el-vehiculo.md | head -5
echo "--F13 binario CI--"; grep -n "CI" 13-testing-de-api.md | head -4
echo "--F12 rele--"; grep -n "relé\|rele tonto\|Curso 01" 12-el-backend-habla.md | head -5
echo "--fecha zona horaria--"; grep -rn "zona horaria\|timezone\|un día menos" *.md | head -5
