"""Revisión de continuidad: identificadores en español dentro de los bloques de código de los .md (guía §4).
Uso: python3 identificadores_es.py <archivo.md>...   Heurística: parte cada identificador en palabras y marca
las que no están en /usr/share/dict/words ni en la lista de términos técnicos."""
import re, sys
ingles = {w.strip().lower() for w in open("/usr/share/dict/words")}
tecnicos = set("""js jsx npm npx api app src env http https url uri json scss css sass html dom ui ux id ids ms bp sec
redux rtk thunk thunks async await const let var func args argv util utils config cfg db prod dev tmp lib libs pkg
axios jest rtl msw cypress req res err ctx btn nav auth jwt cors xhr uuid utc iso ts param params
props prev init lang img src svg png usd cents bg fg rgb rgba px rem em vh vw md lg sm xs xl kbd tbody thead
middleware getter setters setter mock mocks webpack babel eslint polyfill polyfills spinner navbar dropdown
grants grant wheel wheels esclusa googleplay gem gems jewel jewels oxxo efecty canal itzel yariela marisol
ibatista ypinzon mdegracia abdiel juliana interoceanic chaos pkce rxjs epic epics ofype oftype noop
seedrandom mulberry tok idempotency testid href onclick onchange onsubmit classname htmlfor tabindex
localstorage sessionstorage usestate useeffect usememo usecallback uselayouteffect useref useselector usedispatch
usehistory useparams uselocation withrouter fulfilled rejected pending payload reducer reducers dispatch
selector selectors enum enums stdout stderr stdin argv exe sh bash zsh docker dockerfile entrypoint cmd workdir
expose healthcheck curl wget jq grep awk sed xargs tsx cjs mjs dotenv readme gitignore lowdb jsonserver
""".split())
def palabras(ident):
    for parte in re.split(r"[_\-]+", ident):
        for w in re.findall(r"[A-Z]+(?=[A-Z][a-z])|[A-Z]?[a-z]+|[A-Z]+|\d+", parte):
            yield w.lower()
for ruta in sys.argv[1:]:
    texto = open(ruta, encoding="utf-8").read()
    marcados = {}
    for m in re.finditer(r"```(\w*)\n(.*?)```", texto, re.S):
        lang, cod = m.group(1).lower(), m.group(2)
        if lang in ("", "text", "markdown", "md", "mermaid", "diff", "console", "output"):
            continue
        cod = re.sub(r"/\*.*?\*/", " ", cod, flags=re.S)
        cod = re.sub(r"(?m)//.*$", " ", cod)
        if lang in ("bash", "sh", "shell", "zsh", "dockerfile", "yaml", "yml"):
            cod = re.sub(r"(?m)#.*$", " ", cod)
        cod = re.sub(r"`(?:\\.|[^`\\])*`|\"(?:\\.|[^\"\\])*\"|'(?:\\.|[^'\\])*'", " ", cod)
        cod = re.sub(r"<[^<>]*>[^<>{}]*</", "<></", cod)  # texto de JSX entre etiquetas
        for ident in set(re.findall(r"[A-Za-z_][A-Za-z0-9_]*", cod)):
            malas = [w for w in palabras(ident) if len(w) > 2 and not w.isdigit()
                     and w not in ingles and w not in tecnicos and not w.endswith("s") or
                     (w.endswith("s") and len(w) > 3 and w[:-1] not in ingles and w not in ingles and w not in tecnicos and w[:-1] not in tecnicos and not w.isdigit())]
            if malas:
                marcados.setdefault(ident, malas)
    if marcados:
        print(f"== {ruta}: {len(marcados)}")
        for k in sorted(marcados):
            print(f"   {k}  ({', '.join(marcados[k])})")
