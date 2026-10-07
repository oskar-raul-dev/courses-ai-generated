# rescatado de la sesión 5d4ed58d, 2026-09-10T02:27:09Z · Verify false positives and check wide table exceptions
echo "=== muestra de 'vale' ==="; sed -n '428p;831p' cuaderno-incidentes.md; sed -n '13p' 00-convencion-de-git-y-tags.md
echo; echo "=== 'móvil' ==="; sed -n '453p' A1-bootstrap-4-y-sass.md; sed -n '478p;570p' be09-empaquetado-ambientes-y-pipeline.md; sed -n '105p' prompts/guia-de-estilo-y-convenciones.md
echo; echo "=== tablas anchas, cabecera ==="
sed -n '280,281p' be-a-02-receta-de-imagen-y-compose.md; echo "---"; sed -n '122,123p' be09-empaquetado-ambientes-y-pipeline.md; echo "---"; sed -n '320,321p' be09-empaquetado-ambientes-y-pipeline.md; echo "---"; sed -n '117,118p' cuaderno-incidentes-be.md; echo "---"; sed -n '318,319p' prompts/diccionario-codigo-ingles.md
echo; echo "=== ¿la guía documenta estas excepciones? ==="; grep -n "seis columnas\|excepción deliberada a §3\|cinco columnas\|siete columnas" prompts/guia-de-estilo-y-convenciones.md
