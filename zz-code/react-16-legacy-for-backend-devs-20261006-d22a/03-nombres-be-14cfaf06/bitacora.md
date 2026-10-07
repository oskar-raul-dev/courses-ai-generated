# Bitácora de ejecución · sesión 14cfaf06-578d-44da-99e0-ba6788d8c1c8

Comandos que ejecutaron código, con el inicio de su salida.

### ⏱️ 2026-09-12T02:16:09Z · Compare BE naming across all courses

~~~~~~bash
cd /Users/oskar/Developer/Learning/courses-ia-generated
for d in angular-8-legacy-for-backend-devs angular-16-legacy-for-backend-devs react-16-legacy-for-backend-devs docker-container-legacy* ; do echo "=== $d ==="; ls $d 2>/dev/null | grep -E '^be' | head -30; done
~~~~~~

~~~~~~text
=== angular-8-legacy-for-backend-devs ===
be00-el-contrato-auditoria-del-mock.md
be01-java-spring-y-la-forma-del-monolito.md
be02-medir-la-deriva-de-esquema.md
be03-la-costura-y-el-reemplazo.md
be04-el-audit-log-que-escribia-el-navegador.md
be05-la-cadena-de-custodia-y-la-transaccion.md
be06-los-rangos-y-la-historia-perdida.md
be07-la-subida-que-nadie-decidio.md
be08-la-contencion-y-lo-irrecuperable.md
bea-01-java-8-y-spring-para-quien-no-escribe-java.md
bea-02-receta-de-imagen-y-compose.md
bea-03-modelar-documentos-embeber-o-referenciar.md
bea-04-agregaciones-como-instrumento-de-medida.md
bea-05-indices-y-explain-en-mongodb.md
bea-06-jsonschema-sobre-datos-sucios.md
bea-07-transacciones-replica-sets-y-el-standalone.md
bea-08-tiempo-zonas-y-fechas-en-mongo.md
bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md
bea-10-riesgo-de-licencia-sspl.md
bea-11-mapa-de-deuda-del-track-be.md
bea-12-datos-de-prueba-y-volumen.md
=== angular-16-legacy-for-backend-devs ===
be00-el-contrato-auditoria-del-mock.md
be01-lumen-y-la-familiaridad-falsa.md
be02-estratos-por-procedencia.md
be03-el-reemplazo.md
be04-el-salto-de-version-que-nadie-corrio.md
be05-la-invariante-que-no-sostenia-nadie.md
be06-la-reescritura-a-medias.md
be07-el-assessment-de-riesgo.md
bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md
bea-02-receta-de-imagen-y-compose.md
bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md
bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md
bea-05-dialectos-y-saltos-de-version-en-pos
~~~~~~

