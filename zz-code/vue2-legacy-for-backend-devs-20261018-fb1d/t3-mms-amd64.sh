#!/usr/bin/env bash
# T3 (a7 §🧬): los dos comandos publicados, tal cual, desde una copia limpia del backend (más las etiquetas).
cd backend-t3
L="--label curso=vue2-legacy --label tanda=T3"
docker run --rm $L --platform linux/amd64 -v "$PWD":/app -w /app node:14.21.3 npm ci 2>&1 | tail -1
( time docker run --rm $L --platform linux/amd64 -v "$PWD":/app -w /app \
  node:14.21.3 node node_modules/.bin/jest --runInBand --ci ) 2>&1 | grep -E "Tests:|Suites:|^real|did not exit"
