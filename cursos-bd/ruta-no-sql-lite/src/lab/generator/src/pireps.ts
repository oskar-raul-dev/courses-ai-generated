// Reportes de piloto: prosa telegráfica, con jerga y con faltas. Cada arquetipo es una avería
// con varias formas de contarla; el arquetipo es la verdad de referencia que usa F16 para medir
// recall, y va en answers.json, nunca en los datos.
import type { Rng } from "./rng.ts";

export interface Archetype {
  id: string;
  ata: number;
  /** Plantillas: {fase} y {lado} se rellenan; sin ellas la frase va tal cual. */
  templates: string[];
}

export const ARCHETYPES: Archetype[] = [
  { id: "gear-metallic-noise", ata: 32, templates: [
    "ruido metálico al bajar tren, intermitente",
    "golpeteo al extender tren {lado}, se repite en {fase}",
    "se escucha clanc fuerte cuando baja el tren",
    "ruido raro en extension de tren, como metal con metal",
    "tren {lado} suena al desplegar, tripulacion reporta golpe seco",
    "al sacar tren se oye un golpe metalico en {fase}",
  ]},
  { id: "brake-vibration", ata: 32, templates: [
    "vibracion en pedales de freno en {fase}",
    "frenos vibran al aplicar, sensacion de pulsacion",
    "trepidación en freno {lado} durante carreteo",
    "pedal de freno tiembla al frenar suave",
    "vibración fuerte al frenar después del aterrizaje",
  ]},
  { id: "burning-smell", ata: 21, templates: [
    "olor a quemado en cabina durante {fase}",
    "olor electrico a quemado, sin humo visible",
    "pax reportan olor a plastico quemado en {fase}",
    "olor raro a quemado que desaparece al apagar calefaccion",
    "cabina huele a cable caliente en {fase}",
  ]},
  { id: "gear-light", ata: 32, templates: [
    "luz de tren no enciende, tren abajo y asegurado segun inspeccion visual",
    "no hay luz verde de tren {lado} con tren abajo",
    "indicacion de tren {lado} apagada, visual ok",
    "luz tres verdes incompleta, falta una en {fase}",
    "indicador de tren no da verde, se confirma abajo por torre",
  ]},
  { id: "oil-pressure-flicker", ata: 79, templates: [
    "presion de aceite motor {lado} fluctua en {fase}",
    "aguja de presion de aceite oscila sin causa aparente",
    "oil press parpadea en crucero, temp normal",
    "indicacion de presión de aceite inestable motor {lado}",
    "baja momentanea de presion de aceite, se recupera sola",
  ]},
  { id: "radio-static", ata: 23, templates: [
    "radio com 1 con estatica fuerte",
    "comunicaciones con ruido, no se entiende a torre en {fase}",
    "chasquidos en radio al transmitir",
    "com 1 corta y vuelve, estatica intermitente",
    "mucha interferencia en la radio en {fase}",
  ]},
  { id: "egt-high", ata: 77, templates: [
    "EGT alta motor {lado} en ascenso",
    "temperatura de gases arriba de lo normal en {fase}",
    "itt alto en despegue, dentro de limites pero mas que otros dias",
    "egt sube mas de lo normal motor {lado}",
    "temperatura de escape elevada en {fase}, se reduce potencia",
  ]},
  { id: "hydraulic-leak", ata: 29, templates: [
    "fuga hidraulica en pozo de tren {lado}",
    "goteo de liquido rojo bajo el ala {lado}",
    "nivel hidraulico bajo en prevuelo",
    "se encontro liquido hidraulico en rueda {lado} post vuelo",
    "perdida de fluido hidraulico, charco en plataforma",
  ]},
  { id: "door-seal-whistle", ata: 52, templates: [
    "silbido en puerta de cabina en {fase}",
    "ruido de aire por sello de puerta, silba en crucero",
    "puerta de carga silba a alta velocidad",
    "chiflido por la puerta principal en {fase}",
  ]},
  { id: "autopilot-disconnect", ata: 22, templates: [
    "piloto automatico se desconecta solo en {fase}",
    "AP desacopla sin comando, alarma sonora",
    "autopiloto se suelta en turbulencia leve",
    "desconexion del piloto automatico sin causa en {fase}",
  ]},
];

const PHASES = ["despegue", "ascenso", "crucero", "descenso", "aproximacion", "aterrizaje", "carreteo", "rodaje", "ascenso inicial", "final corta"];
const SIDES = ["izquierdo", "derecho", "izq", "der", "de nariz", "principal", "#1", "#2"];
// quién lo cuenta y cómo empieza: la tripulación no escribe dos veces igual
const OPENINGS = ["", "", "", "PIC reporta ", "tripulacion informa ", "copiloto nota ", "en vuelo: ", "post vuelo ", "OBS: ", "reporte: "];
// el detalle que se anota con prisa: números distintos en cada reporte
const DETAILS: ((rng: Rng) => string)[] = [
  () => "",
  () => "",
  (rng) => `, FL${rng.int(60, 250)}`,
  (rng) => ` a ${rng.int(2, 18) * 500} ft`,
  (rng) => `, OAT ${rng.int(-15, 38)}`,
  (rng) => `, ${rng.int(2, 6)} vuelos seguidos`,
  (rng) => ` a ${rng.int(95, 240)} kt`,
  (rng) => `, desde hace ${rng.int(2, 15)} dias`,
  (rng) => `, pax ${rng.int(1, 19)} a bordo`,
  (rng) => ` tramo ${rng.pick(["VVC", "BOG", "EJA", "NVA", "IQT", "OCC", "MVP", "LET", "PPN", "SJE"])}-${rng.pick(["VVC", "BOG", "PCR", "MIT", "CUI", "TRB", "LQM", "SVI"])}`,
];
const SUFFIXES = ["", "", "", ". Favor revisar", ", segundo vuelo con lo mismo", ". tripulacion atenta", ", reportado tambien ayer", ". sin mas novedad", ". se anota en libro", ", verificar antes del proximo vuelo"];
// la jerga de plataforma: la misma cosa con otras palabras
const SYNONYMS: [RegExp, string[]][] = [
  [/\bruido\b/g, ["ruido", "sonido", "ruidito", "traqueteo"]],
  [/\btren\b/g, ["tren", "tren de aterrizaje", "LG", "tren de aterrizaje"]],
  [/\bcabina\b/g, ["cabina", "cockpit", "cabina de mando", "cabina"]],
  [/\bmotor\b/g, ["motor", "mtr", "planta", "motor"]],
  [/\bintermitente\b/g, ["intermitente", "a ratos", "no siempre", "de vez en cuando"]],
  [/\bfuerte\b/g, ["fuerte", "duro", "bien marcado"]],
  [/\bpresion\b/g, ["presion", "press", "presión"]],
  [/\bfuga\b/g, ["fuga", "goteo", "bote"]],
  [/\bradio\b/g, ["radio", "com", "VHF"]],
];

/** Faltas de teclado: quita tildes, intercambia letras vecinas o duplica una. */
function typos(rng: Rng, text: string): string {
  let out = text;
  if (rng.chance(0.5)) out = out.normalize("NFD").replace(/[̀-ͯ]/g, "");
  const swaps = rng.chance(0.4) ? rng.int(1, 2) : 0;
  for (let i = 0; i < swaps; i++) {
    const p = rng.int(1, Math.max(1, out.length - 2));
    if (/[a-z]/.test(out[p]) && /[a-z]/.test(out[p + 1])) out = out.slice(0, p) + out[p + 1] + out[p] + out.slice(p + 2);
  }
  if (rng.chance(0.3)) out = out.toUpperCase();
  return out;
}

export function writePirepText(rng: Rng, archetype: Archetype): string {
  const template = rng.pick(archetype.templates);
  let text = template.replace("{fase}", rng.pick(PHASES)).replace("{lado}", rng.pick(SIDES));
  for (const [pattern, options] of SYNONYMS) text = text.replace(pattern, () => rng.pick(options));
  text = rng.pick(OPENINGS) + text + rng.pick(DETAILS)(rng) + rng.pick(SUFFIXES);
  return typos(rng, text);
}
