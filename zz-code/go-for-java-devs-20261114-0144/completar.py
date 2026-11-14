#!/usr/bin/env python3
"""Completa en lector/ lo que las fases omiten a propósito ("// ... como en la Fase 01 ...").
Cada regla dice qué línea de qué archivo se sustituye y con qué. Se corre después de extraer.py.
Uso: python3 completar.py [regla…]   (sin argumentos, todas las que apliquen)"""
import pathlib, re, sys
AQUI = pathlib.Path(__file__).resolve().parent
LECTOR, VERS = AQUI / "lector", AQUI / "salidas" / "versiones"

def tramo(version, desde, hasta):
    """Líneas de una versión guardada, desde la que casa `desde` hasta antes de la que casa `hasta`."""
    L = (VERS / version).read_text(encoding="utf-8").split("\n")
    i = next(k for k, l in enumerate(L) if re.search(desde, l))
    j = next(k for k, l in enumerate(L[i+1:], i+1) if re.search(hasta, l))
    return L[i:j]

def anotar(archivo):
    with open(AQUI / "salidas" / "fusionados.txt", "a", encoding="utf-8") as fz:
        fz.write(archivo + "\n")

def sustituir(archivo, marca, nuevas):
    anotar(archivo)
    f = LECTOR / archivo
    L = f.read_text(encoding="utf-8").split("\n")
    k = [n for n, l in enumerate(L) if re.search(marca, l)]
    if not k:
        return False
    fin = k[0] + 1
    while fin < len(L) and L[fin].startswith("// ") and L[fin].rstrip().endswith("...") and not L[k[0]].rstrip().endswith("..."):
        fin += 1  # la marca sigue en la línea siguiente
    if L[k[0]].rstrip().endswith(",") or not L[k[0]].rstrip().endswith("..."):
        while fin < len(L) and L[fin].startswith("//") and not L[fin-1].rstrip().endswith("..."):
            fin += 1
    L[k[0]:fin] = nuevas
    f.write_text("\n".join(L), encoding="utf-8")
    return True

def quitar_decl(archivo, cabeza):
    """Quita una declaración de nivel superior (con su comentario previo) que empieza con `cabeza`."""
    f = LECTOR / archivo
    if not f.exists(): return False
    L = f.read_text(encoding="utf-8").split("\n")
    k = next((n for n, l in enumerate(L) if l.startswith(cabeza)), None)
    if k is None: return False
    ini = k
    while ini > 0 and L[ini-1].startswith("//"): ini -= 1
    fin = k + 1
    if L[k].rstrip().endswith(("(", "{")):
        while fin < len(L) and L[fin-1] not in (")", "}"): fin += 1
    del L[ini:fin]
    f.write_text("\n".join(L), encoding="utf-8")
    return True

def escribir(archivo, texto):
    anotar(archivo)
    f = LECTOR / archivo
    if not f.parent.exists(): return False
    f.write_text(texto, encoding="utf-8"); return True

def relay_errors():
    w = (LECTOR / "services/opsreport/internal/workitem/errors.go")
    if not w.exists() or not (LECTOR / "services/eventrelay/internal/relay").exists(): return False
    L = w.read_text(encoding="utf-8").split("\n")
    i = next(n for n, l in enumerate(L) if l.startswith("// FieldError"))
    j = next(n for n, l in enumerate(L) if l.startswith("// TransitionError"))
    return escribir("services/eventrelay/internal/relay/errors.go",
        "// Copia de workitem/errors.go (F03): dos módulos, sin paquete común.\npackage relay\n\nimport \"strings\"\n\n" + "\n".join(L[i:j]))

GENERADOR = """func buildLargeDocument(n int) []byte {
	// Completado en zz-code: la fase lo deja como ejercicio.
	base := time.Date(2026, 9, 1, 8, 0, 0, 0, time.UTC)
	items := make([]WorkItemJSON, n)
	for i := range items {
		items[i] = WorkItemJSON{
			ID: fmt.Sprintf("WI-%06d", i), ExternalReference: fmt.Sprintf("SAP-2026-%06d", i),
			Kind: "reconciliation", Description: "Conciliación de tiendas del norte",
			Priority: i%9 + 1, EffectivePriority: i%9 + 1, Status: "done", CreatedAt: base.Add(time.Duration(i) * time.Minute),
		}
	}
	data, err := json.Marshal(items)
	if err != nil {
		panic(err)
	}
	return data
}"""

CURSO = AQUI.parent.parent / "cursos-algoritmos-lenguajes" / "go-for-java-devs"

def bloque(fase, primera, lang="go"):
    """Cuerpo del primer bloque go de la fase cuya primera línea casa con `primera`."""
    f = next(CURSO.glob(fase + "-*.md"))
    L = f.read_text(encoding="utf-8").split("\n")
    for i, l in enumerate(L):
        if l.startswith("```" + lang) and i + 1 < len(L) and re.search(primera, L[i+1]):
            j = next(k for k in range(i+1, len(L)) if L[k].startswith("```"))
            return L[i+1:j]
    raise KeyError(primera)

def copiar(fase, primera, destino, paquete=None, añadir=False, imports=()):
    """Escribe (o añade) un bloque sin ruta en `destino`; con `paquete`, le pone la cabecera."""
    f = LECTOR / destino
    if not f.parent.exists(): return False
    cuerpo = bloque(fase, primera)
    if añadir and f.exists():
        texto = f.read_text(encoding="utf-8").rstrip("\n") + "\n\n" + "\n".join(cuerpo) + "\n"
    else:
        cab = f"package {paquete}\n\n" if paquete else ""
        if imports:
            cab += "import (\n" + "".join(f'\t"{i}"\n' for i in imports) + ")\n\n"
        texto = cab + "\n".join(cuerpo) + "\n"
    anotar(destino)
    f.write_text(texto, encoding="utf-8"); return True

def reemplazar_en(archivo, desde, viejo, nuevo):
    """Reemplaza la primera aparición de `viejo` después de la línea que contiene `desde`."""
    f = LECTOR / archivo
    if not f.exists(): return False
    t = f.read_text(encoding="utf-8"); i = t.find(desde)
    if i < 0 or t.find(viejo, i) < 0: return False
    j = t.find(viejo, i); f.write_text(t[:j] + nuevo + t[j+len(viejo):], encoding="utf-8")
    anotar(archivo); return True

def makefile_f04():
    f = LECTOR / "Makefile"
    if not f.exists(): return False
    mk = f.read_text(encoding="utf-8")
    nuevo = bloque("04", r"^COVER_PKGS", "makefile")
    a = mk.index("cover: ##"); b = mk.index("up: ##")
    mk = mk[:a] + "\n".join(nuevo[2:]) + "\n\n" + mk[b:]
    mk = mk.replace("COVER_MIN  ?= 80\n", "COVER_MIN  ?= 80\n" + nuevo[0] + "\n", 1)
    f.write_text(mk, encoding="utf-8"); return True

def quitar_bloque_con(archivo, texto):
    """Quita el var ( … ) o const ( … ) que contiene `texto`, con su comentario previo."""
    f = LECTOR / archivo
    if not f.exists(): return False
    L = f.read_text(encoding="utf-8").split("\n")
    k = next((n for n, l in enumerate(L) if texto in l), None)
    if k is None: return False
    ini = k
    while ini > 0 and not L[ini].startswith(("var (", "const (")): ini -= 1
    fin = k
    while L[fin] != ")": fin += 1
    while ini > 0 and L[ini-1].startswith("//"): ini -= 1
    del L[ini:fin+1]
    f.write_text("\n".join(L), encoding="utf-8"); anotar(archivo); return True

def labs_a_internal(servicio, mapa):
    """Copia los labs a internal/ del servicio (F05: 'los labs se mudan al servicio')."""
    base = LECTOR / servicio
    if not (base / "internal").exists(): return False
    hecho = False
    for lab, pkg in mapa.items():
        src = LECTOR / "labs" / lab
        if not src.exists(): continue
        dst = base / "internal" / pkg; dst.mkdir(parents=True, exist_ok=True)
        for f in src.glob("*.go"):
            if f.name.endswith("_test.go"): continue
            (dst / f.name).write_text(f.read_text(encoding="utf-8"), encoding="utf-8")
            anotar(f"{servicio}/internal/{pkg}/{f.name}"); hecho = True
    return hecho

HEALTH = """package httpapi

import (
	"net/http"

	"github.com/meridian/opsreport/internal/router"
)

// Completado en zz-code: la fase lo usa en main y lo deja al ejercicio 2.
type HealthHandler struct{}

func NewHealthHandler() *HealthHandler { return &HealthHandler{} }

func (h *HealthHandler) Register(r *router.Router) {
	r.GET("/health", func(w http.ResponseWriter, _ *http.Request, _ router.Params) {
		w.Header().Set("Content-Type", "application/json")
		if _, err := w.Write([]byte(`{"status":"ok"}`)); err != nil {
			return
		}
	})
}
"""

AYUDANTES_HTTP = """package httpapi

import (
	"errors"
	"strings"
	"time"

	"github.com/meridian/opsreport/internal/workitem"
)

// Completado en zz-code: la F05 enumera estos ayudantes y los deja al lector.

type workItemJSON struct {
	ID                string     `json:"id"`
	ExternalReference string     `json:"external_reference"`
	Kind              string     `json:"kind"`
	Description       string     `json:"description,omitempty"`
	Priority          int        `json:"priority"`
	EffectivePriority int        `json:"effective_priority"`
	Status            string     `json:"status"`
	CreatedAt         time.Time  `json:"created_at"`
	StartedAt         *time.Time `json:"started_at,omitempty"`
	FinishedAt        *time.Time `json:"finished_at,omitempty"`
	FailureReason     string     `json:"failure_reason,omitempty"`
}

type listResponse struct {
	Items []workItemJSON `json:"items"`
	Count int            `json:"count"`
}

func optTime(t time.Time) *time.Time {
	if t.IsZero() {
		return nil
	}
	u := t.UTC()
	return &u
}

func toJSON(w workitem.WorkItem, now time.Time) workItemJSON {
	return workItemJSON{
		ID: w.ID, ExternalReference: w.ExternalReference, Kind: string(w.Kind), Description: w.Description,
		Priority: int(w.Priority), EffectivePriority: int(w.EffectivePriority(now)), Status: string(w.Status),
		CreatedAt: w.CreatedAt.UTC(), StartedAt: optTime(w.StartedAt), FinishedAt: optTime(w.FinishedAt),
		FailureReason: w.FailureReason,
	}
}

func toJSONList(items []workitem.WorkItem, now time.Time) []workItemJSON {
	out := make([]workItemJSON, 0, len(items))
	for _, it := range items {
		out = append(out, toJSON(it, now))
	}
	return out
}

func filterByStatus(items []workitem.WorkItem, st workitem.Status) []workitem.WorkItem {
	var out []workitem.WorkItem
	for _, it := range items {
		if it.Status == st {
			out = append(out, it)
		}
	}
	return out
}

// decodeError: parche de época; en 1.13 el límite de MaxBytesReader solo se ve en el texto.
func decodeError(err error) error {
	if strings.Contains(err.Error(), "http: request body too large") {
		return errBodyTooLarge
	}
	return errBadJSON
}

var _ = errors.New
"""

GET_CANCEL = """
// Get devuelve un work item. Completado en zz-code (la F05 lo deja al lector).
func (s *Service) Get(id string) (workitem.WorkItem, error) {
	item, err := s.store.FindByID(id)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			return workitem.WorkItem{}, fmt.Errorf("work item %s: %w", id, err)
		}
		return workitem.WorkItem{}, fmt.Errorf("%w: %v", ErrStorage, err)
	}
	return item, nil
}

// Cancel lleva un work item a cancelled. Completado en zz-code.
func (s *Service) Cancel(id string) (workitem.WorkItem, error) {
	item, err := s.Get(id)
	if err != nil {
		return workitem.WorkItem{}, err
	}
	if !item.CanTransitionTo(workitem.StatusCancelled) {
		return workitem.WorkItem{}, fmt.Errorf("%w: %v", ErrConflict, &workitem.TransitionError{From: item.Status, To: workitem.StatusCancelled})
	}
	item.Status = workitem.StatusCancelled
	item.FinishedAt = s.clock.Now()
	if err := s.store.Update(item); err != nil {
		return workitem.WorkItem{}, fmt.Errorf("%w: %v", ErrStorage, err)
	}
	return item, nil
}
"""

def anexar(archivo, texto, si_no_contiene):
    f = LECTOR / archivo
    if not f.exists(): return False
    t = f.read_text(encoding="utf-8")
    if si_no_contiene in t: return False
    f.write_text(t.rstrip("\n") + "\n" + texto, encoding="utf-8"); anotar(archivo); return True

MUST_HTTP = """package httpapi_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

// Completado en zz-code: la F05 los deja al lector.
func mustPost(t *testing.T, api http.Handler, path string, want int) *httptest.ResponseRecorder {
	t.Helper()
	rec := httptest.NewRecorder()
	api.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, path, nil))
	if rec.Code != want {
		t.Fatalf("POST %s = %d, quería %d: %s", path, rec.Code, want, rec.Body.String())
	}
	return rec
}

func mustCreateViaAPI(t *testing.T, api http.Handler, ref string) struct{ ID string } {
	t.Helper()
	body := `{"external_reference":"` + ref + `","kind":"import","priority":3}`
	rec := httptest.NewRecorder()
	api.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, "/work-items", strings.NewReader(body)))
	if rec.Code != http.StatusCreated {
		t.Fatalf("crear = %d: %s", rec.Code, rec.Body.String())
	}
	var out struct {
		ID string `json:"id"`
	}
	if err := json.Unmarshal(rec.Body.Bytes(), &out); err != nil {
		t.Fatal(err)
	}
	return struct{ ID string }{out.ID}
}
"""

def stubs(tanda):
    """Copia stubs/<tanda>/… a lector/ si el directorio destino existe (piezas que la fase omite)."""
    hecho = False
    for f in (AQUI / "stubs" / tanda).rglob("*.go"):
        rel = f.relative_to(AQUI / "stubs" / tanda)
        if (LECTOR / rel).parent.exists():
            escribir(str(rel), f.read_text(encoding="utf-8")); hecho = True
    return hecho

REGLAS = {
    "f02-workitem-tipos": lambda: sustituir(
        "services/opsreport/internal/workitem/workitem.go",
        r"^// \.\.\. Status, Kind, Priority",
        tramo("services/opsreport/internal/workitem/workitem.go.01", r"^// Status es", r"^// WorkItem es")
        + tramo("services/opsreport/internal/workitem/workitem.go.01", r"^// Los errores de validación", r"^// Validate comprueba")
        + tramo("services/opsreport/internal/workitem/workitem.go.01", r"^// agingBoost", r"^// EffectivePriority")),
    "f03-errinvalid-mudanza": lambda: (LECTOR / "services/opsreport/internal/workitem/errors.go").exists()
        and quitar_decl("services/opsreport/internal/workitem/workitem.go", "var ErrInvalidTransition"),
    "f03-relay-errors": relay_errors,
    "f03-errores-f01-fuera": lambda: (LECTOR / "services/opsreport/internal/workitem/errors.go").exists()
        and quitar_bloque_con("services/opsreport/internal/workitem/workitem.go", "errEmptyExternalReference ="),
    "f03-generador-json": lambda: sustituir("labs/json-codec/decode_bench_test.go",
        r"^func buildLargeDocument\(n int\) \[\]byte \{ /\*", GENERADOR.split("\n")),
    "f04-priority-test": lambda: copiar("04", r"^func TestEffectivePriority",
        "services/opsreport/internal/workitem/priority_test.go", paquete="workitem_test",
        imports=("testing", "time", "github.com/meridian/opsreport/internal/workitem")),
    "f03-create-errstorage": lambda: reemplazar_en("services/opsreport/internal/opsreport/service.go",
        "func (s *Service) Create(", "\tif err := s.store.Save(item); err != nil {\n\t\treturn workitem.WorkItem{}, err\n",
        "\tif err := s.store.Save(item); err != nil {\n\t\treturn workitem.WorkItem{}, fmt.Errorf(\"%w: %v\", ErrStorage, err)\n"),
    "f04-makefile-cover": makefile_f04,
    "f05-middleware-continuacion": lambda: copiar("05", r"^// RequestID asigna", "labs/middleware-chain/middleware.go", añadir=True),
    "f05-labs-a-internal": lambda: (LECTOR / "services/opsreport/internal/httpapi").exists() and labs_a_internal("services/opsreport",
        {"tiny-router": "router", "middleware-chain": "middleware", "config-loader": "config", "fake-clock": "clock"}),
    "f05-health": lambda: (LECTOR / "services/opsreport/internal/httpapi").exists() and escribir("services/opsreport/internal/httpapi/health.go", HEALTH),
    "f05-ayudantes-http": lambda: (LECTOR / "services/opsreport/internal/httpapi/workitems.go").exists()
        and escribir("services/opsreport/internal/httpapi/helpers.go", AYUDANTES_HTTP),
    "f05-get-cancel": lambda: (LECTOR / "services/opsreport/internal/httpapi").exists()
        and anexar("services/opsreport/internal/opsreport/service.go", GET_CANCEL, "func (s *Service) Get("),
    "f05-fakes-httpapi": lambda: (LECTOR / "services/opsreport/internal/httpapi/workitems_test.go").exists()
        and escribir("services/opsreport/internal/httpapi/fakes_test.go",
            (LECTOR / "services/opsreport/internal/opsreport/fakes_test.go").read_text(encoding="utf-8")
            .replace("package opsreport_test", "package httpapi_test")
            .replace("type fakeClock struct{ now time.Time }\n\nfunc (c *fakeClock) Now() time.Time { return c.now }\n", "")),
    "f05-must-http": lambda: (LECTOR / "services/opsreport/internal/httpapi/workitems_test.go").exists()
        and escribir("services/opsreport/internal/httpapi/must_test.go", MUST_HTTP),
    "f06-stubs": lambda: stubs("f06"),
    "f06-leak-busquedas": lambda: anexar("labs/leak-lab/leak.go", (AQUI / "stubs/f06-anexos/leak.go.txt").read_text(encoding="utf-8"), "func searchDB("),
    "f06-dispatcher-relay": lambda: reemplazar_en("services/eventrelay/internal/dispatcher/dispatcher.go", "package dispatcher",
        "package dispatcher\n", "package dispatcher\n\nimport \"github.com/meridian/eventrelay/internal/relay\"\n"),
    "f07-stubs": lambda: stubs("f07"),
    "f08-movement-string": lambda: (LECTOR / "labs/movement-parser/parse_fuzz_test.go").exists()
        and anexar("labs/movement-parser/main.go", (AQUI / "stubs/f08-anexos/movement-string.txt").read_text(encoding="utf-8"), "func (m Movement) String()"),
    "f09-stubs": lambda: stubs("f09"),
    "f09-relay-import": lambda: reemplazar_en("services/eventrelay/internal/postgres/delivery.go", "package postgres",
        "package postgres\n", "package postgres\n\nimport \"github.com/meridian/eventrelay/internal/relay\"\n"),
}

if __name__ == "__main__":
    for nombre in (sys.argv[1:] or REGLAS):
        print(f"{nombre}: {'aplicada' if REGLAS[nombre]() else 'no aplica'}")
