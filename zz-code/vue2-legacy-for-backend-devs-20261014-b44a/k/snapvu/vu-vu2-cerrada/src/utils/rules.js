// Reglas reutilizables. Cada una es (o devuelve) una función val => true | string.
export var required = function (msg) {
  return function (v) {
    return !!v || (msg || "Campo obligatorio.");
  };
};

export var minLen = function (n, msg) {
  return function (v) {
    return (v && v.length >= n) || (msg || "Mínimo " + n + " caracteres.");
  };
};

export var maxLen = function (n, msg) {
  return function (v) {
    return (!v || v.length <= n) || (msg || "Máximo " + n + " caracteres.");
  };
};

export var oneOf = function (values, msg) {
  return function (v) {
    return values.indexOf(v) !== -1 || (msg || "Valor no permitido.");
  };
};
