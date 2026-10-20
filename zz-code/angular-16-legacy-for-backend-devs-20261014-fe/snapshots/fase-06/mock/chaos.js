// mock/chaos.js
const DEFAULT_DELAY_MS = 2500;
const DEFAULT_RATE = 0.3;

const KNOWN_FAULTS = ['latency', 'error', 'malformed', 'cors', 'expired', 'timeout'];

function readChaosConfig(env) {
  const raw = (env.CHAOS ?? '').trim();
  const faults = raw === '' ? [] : raw.split(',').map((fault) => fault.trim()).filter(Boolean);

  const unknown = faults.filter((fault) => !KNOWN_FAULTS.includes(fault));

  if (unknown.length > 0) {
    // Falla al arrancar, no en silencio. Un CHAOS=latencia mal escrito que
    // simplemente no hace nada te cuesta veinte minutos buscando un bug que no
    // existe. Un servidor que se niega a arrancar te cuesta cero.
    throw new Error(
      `Fallos de caos desconocidos: ${unknown.join(', ')}. Los válidos son: ${KNOWN_FAULTS.join(', ')}.`,
    );
  }

  return {
    faults,
    delayMs: Number(env.CHAOS_DELAY_MS ?? DEFAULT_DELAY_MS),
    rate: Number(env.CHAOS_RATE ?? DEFAULT_RATE),
  };
}

function createChaosMiddleware(chaos) {
  const has = (fault) => chaos.faults.includes(fault);
  // La probabilidad se tira UNA vez por petición y se reutiliza: si cada fallo
  // tirara su propio dado, con dos flags activos la mitad de las peticiones
  // saldrían ilesas y el escenario dejaría de ser reproducible.
  const rolls = () => Math.random() < chaos.rate;

  function applyResponseFaults(request, response, next) {
    if (has('timeout') && rolls()) {
      // Ni respondemos ni llamamos a next(). La petición se queda colgada para
      // siempre, que es exactamente lo que hace un backend que se atascó: no
      // manda un error, no cierra la conexión, no dice nada.
      return;
    }

    if (has('error') && rolls()) {
      return response.status(500).json({ message: 'Fallo interno del servidor' });
    }

    if (has('malformed') && rolls()) {
      // Envolvemos response.json para corromper el cuerpo justo antes de salir.
      // Fíjate en que el status sigue siendo 200: en Network todo está verde.
      // json-server responde con res.jsonp, no con res.json: sin parchear jsonp,
      // las colecciones salen intactas (corrección de FE3 sobre la lección).
      const originalJson = response.json.bind(response);
      const originalJsonp = response.jsonp.bind(response);
      response.json = (body) => originalJson(corruptPayload(body));
      response.jsonp = (body) => originalJsonp(corruptPayload(body));
    }

    next();
  }

  return (request, response, next) => {
    // El caos no toca la autenticación. `expired` es la excepción y vive en auth.js.
    if (request.path.startsWith('/auth/')) {
      return next();
    }

    if (has('latency')) {
      // El retraso es incondicional: una latencia intermitente no se distingue
      // de un problema de red, y aquí queremos que se distinga.
      return setTimeout(() => applyResponseFaults(request, response, next), chaos.delayMs);
    }

    applyResponseFaults(request, response, next);
  };
}

/**
 * Dos corrupciones, y las dos son fallos reales de despliegue, no maldades
 * inventadas: envolver un array en un objeto (el clásico cambio a una respuesta
 * paginada que nadie avisó) y cambiar el tipo de un campo numérico.
 */
function corruptPayload(body) {
  if (Array.isArray(body)) {
    return { items: body, total: body.length };
  }

  if (body !== null && typeof body === 'object' && typeof body.version === 'number') {
    return { ...body, version: String(body.version) };
  }

  return body;
}

module.exports = { readChaosConfig, createChaosMiddleware, KNOWN_FAULTS };
