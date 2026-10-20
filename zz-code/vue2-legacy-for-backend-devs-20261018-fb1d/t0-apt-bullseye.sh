#!/usr/bin/env bash
# T0.5: apt en node:14.21.3-bullseye-slim con las fuentes de la imagen, sin security, y con archive.debian.org.
set -u
pk="python3 make g++ git"
for modo in imagen sin-security archive; do
  case $modo in
    imagen) pre=":";;
    sin-security) pre='sed -i "/security/d" /etc/apt/sources.list';;
    archive) pre='printf "%s\n" "deb http://archive.debian.org/debian bullseye main" "deb http://archive.debian.org/debian bullseye-updates main" "deb http://archive.debian.org/debian-security bullseye-security main" > /etc/apt/sources.list';;
  esac
  echo "== $modo"
  docker run --rm --label curso=vue2-legacy --label tanda=T0 node:14.21.3-bullseye-slim bash -c \
    "$pre; apt-get update -qq && apt-get install -y -qq --no-install-recommends $pk > /tmp/out 2>&1; e=\$?; grep -m3 '404\|^E:' /tmp/out; echo EXIT=\$e"
done
