#!/usr/bin/env python3
"""Alias backend: aplica a la copia de trabajo del frontend de F11 el ejercicio 9 de la Fase 11 del Curso 02
(el login contra POST /auth/login real). Uso: python3 -I login-real.py <copia del frontend>
"""
import os
import sys

p = os.path.join(sys.argv[1], "src/services/authService.js")
t = open(p, encoding="utf-8").read()
ini = t.index("var MOCK_USER")
fin = t.index("function saveSession")
nuevo = '''import apiClient from "./apiClient";

// la ruptura pactada de la Fase 11 del Curso 02: el login va al backend real y trae un JWT firmado
function login(username, password) {
  return apiClient
    .post("/auth/login", { username: username, password: password })
    .then(function (res) {
      return { token: res.data.token, user: res.data.user };
    })
    .catch(function () {
      throw new Error("Credenciales inválidas");
    });
}

'''
open(p, "w", encoding="utf-8").write(t[:ini] + nuevo + t[fin:])
print("login real aplicado en", p)
