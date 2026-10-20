import { Injectable } from '@angular/core';

import { AppConfig } from './app-config.model';

@Injectable({ providedIn: 'root' })
export class AppConfigService {
  private config: AppConfig | null = null;

  /**
   * Se llama UNA vez, desde el APP_INITIALIZER de 5.2, antes de que exista
   * ningún componente.
   *
   * Se usa `fetch` y no `HttpClient`, y la razón es la cadena de interceptores:
   * el `authInterceptor` de la Fase 2 le pondría un `Authorization` a esta
   * petición y trataría un 401 como sesión caducada, mandando al usuario al
   * login antes de que la aplicación exista. Pedir un archivo estático del
   * propio servidor no necesita nada de eso.
   *
   * El `?t=` es antichaché y es deliberado: el navegador guarda respuestas de
   * `fetch` igual que las de cualquier petición, y un `config.json` cacheado es
   * exactamente el incidente 18. En 5.5 nginx lo prohíbe además desde su lado;
   * las dos defensas juntas no sobran, porque entre el navegador y nginx suele
   * haber un proxy corporativo que nadie controla.
   */
  async load(): Promise<void> {
    const response = await fetch(`assets/config.json?t=${Date.now()}`);

    if (!response.ok) {
      // Se lanza y se deja morir la aplicación a propósito. Una SPA que arranca
      // sin saber con qué backend habla no está "degradada": está rota, y va a
      // producir cinco tickets confusos en vez de uno claro. El mensaje va en
      // español, como todos los dirigidos a otro desarrollador.
      throw new Error(
        `No se pudo leer assets/config.json (HTTP ${response.status}). La aplicación no puede arrancar sin configuración.`,
      );
    }

    // `unknown` y estrechar, que es la regla desde la Fase 6. Un
    // `await response.json()` devuelve `any` en las definiciones de
    // TypeScript, y aceptarlo aquí apagaría `strict` en el punto exacto donde
    // entra un dato que nadie controla.
    const raw: unknown = await response.json();

    this.config = parseAppConfig(raw);
  }

  /**
   * El acceso. Lanza si alguien lo llama antes de que el initializer
   * terminara, que sólo puede pasar si alguien inyecta este servicio DENTRO de
   * otro APP_INITIALIZER — y entonces el error dice exactamente eso en vez de
   * devolver una cadena vacía que produce peticiones a `/undefined/clients`.
   */
  get current(): AppConfig {
    if (this.config === null) {
      throw new Error('AppConfigService: se pidió la configuración antes de cargarla.');
    }

    return this.config;
  }
}

/**
 * La guarda de forma, que es la misma disciplina que la Fase 3 puso en el
 * borde HTTP y la Fase 9 en los hallazgos. Aquí importa más que en ningún
 * sitio: este archivo lo escribe un shell script desde variables de entorno,
 * así que un despliegue con una variable mal puesta produce un JSON válido y
 * equivocado. Es el incidente 19.
 */
function parseAppConfig(raw: unknown): AppConfig {
  if (typeof raw !== 'object' || raw === null) {
    throw new Error('assets/config.json no contiene un objeto.');
  }

  const candidate = raw as Record<string, unknown>;
  const apiBaseUrl = candidate['apiBaseUrl'];
  const environmentName = candidate['environmentName'];

  if (typeof apiBaseUrl !== 'string' || apiBaseUrl === '') {
    throw new Error('assets/config.json: `apiBaseUrl` falta o está vacío.');
  }

  if (
    environmentName !== 'DEV' &&
    environmentName !== 'UAT' &&
    environmentName !== 'PROD'
  ) {
    // Se comprueba contra los tres valores del tipo y no con un `as`. Una
    // variable de entorno mal escrita —`PRD` en vez de `PROD`— tiene que
    // reventar aquí, en el arranque, con un mensaje que la nombra; no tres
    // pantallas más allá con una etiqueta rara en la toolbar.
    throw new Error(
      `assets/config.json: \`environmentName\` vale "${String(environmentName)}" y sólo admite DEV, UAT o PROD.`,
    );
  }

  return { apiBaseUrl, environmentName };
}
