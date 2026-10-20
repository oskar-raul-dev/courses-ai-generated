// src/utils/rules.js
// Reglas reutilizables para :rules de Quasar.
// Cada función devuelve true (pasa) o un STRING (el mensaje de error).

export function required(val) {
  // ⚠️ !!val rechaza el 0. Si algún día validas números, cámbialo.
  return !!val || "Este campo es obligatorio.";
}

export function minLen(n) {
  return function (val) {
    return (val && val.length >= n) || "Mínimo " + n + " caracteres.";
  };
}

export function maxLen(n) {
  return function (val) {
    return (!val || val.length <= n) || "Máximo " + n + " caracteres.";
  };
}

// El oneOf de F5, portado tal cual. Cambia la firma, no la idea.
export function oneOf(valores, mensaje) {
  return function (val) {
    return valores.indexOf(val) !== -1 || (mensaje || "Valor no permitido.");
  };
}

// El "no grites" del ejercicio 12 de F5, ahora de casa.
export function notAllCaps(val) {
  if (!val || val.length <= 10) { return true; }
  return val !== val.toUpperCase() || "No hace falta gritar. 🙂";
}
