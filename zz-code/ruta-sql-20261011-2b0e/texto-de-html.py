#!/usr/bin/env python3
"""Convierte un HTML guardado en texto plano (uso: texto-de-html.py entrada.html salida.txt)."""
import html, re, sys
t = open(sys.argv[1], encoding="utf-8", errors="replace").read()
t = re.sub(r"<script.*?</script>|<style.*?</style>", "", t, flags=re.S)
t = re.sub(r"<(br|p|li|h\d|div)[^>]*>", "\n", t)
t = html.unescape(re.sub(r"<[^>]+>", " ", t))
t = "\n".join(re.sub(r"[ \t]+", " ", l).strip() for l in t.splitlines())
open(sys.argv[2], "w").write(re.sub(r"\n{3,}", "\n\n", t))
