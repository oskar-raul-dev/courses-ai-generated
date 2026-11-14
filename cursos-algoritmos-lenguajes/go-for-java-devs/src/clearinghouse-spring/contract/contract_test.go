// La suite de contrato HTTP del duelo (Fase 16), apuntada a cualquiera de las dos
// implementaciones con CLEARINGHOUSE_URL. Si las dos no pasan la MISMA suite, no hay
// comparación que hacer.
//
//	CLEARINGHOUSE_URL=http://localhost:8080 go test -v -count=1 .   # Go
//	CLEARINGHOUSE_URL=http://localhost:8081 go test -v -count=1 .   # Spring Boot
//
// Necesita la base recién migrada (V1 y V2) y sin cierres del día 2030-01-15.
package contract

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"
)

type contractCase struct {
	name          string
	method, path  string
	body          string
	wantStatus    int
	wantBodyMatch func(t *testing.T, body []byte)
}

// Un prefijo distinto por corrida: la suite se puede repetir contra la misma base.
var run = fmt.Sprintf("C%d", time.Now().UnixNano()%1_000_000_000)

func hasCode(code string) func(*testing.T, []byte) {
	return func(t *testing.T, b []byte) {
		var e struct {
			Code string `json:"code"`
		}
		if err := json.Unmarshal(b, &e); err != nil || e.Code != code {
			t.Errorf("code = %q (%s), quería %q", e.Code, b, code)
		}
	}
}

func jsonField(field string, want any) func(*testing.T, []byte) {
	return func(t *testing.T, b []byte) {
		var m map[string]any
		if err := json.Unmarshal(b, &m); err != nil {
			t.Fatalf("no es JSON: %s", b)
		}
		if fmt.Sprint(m[field]) != fmt.Sprint(want) {
			t.Errorf("%s = %v, quería %v (%s)", field, m[field], want, b)
		}
	}
}

func syncBody(refs ...string) string {
	var ms []string
	for i, r := range refs {
		typ := []string{"sale", "refund", "void"}[i%3]
		ms = append(ms, fmt.Sprintf(`{"external_ref":"%s-%s","type":"%s","amount_minor":%d,"currency":"COP","occurred_at":"2030-01-15T15:04:05Z"}`,
			run, r, typ, 1000*(i+1)))
	}
	return `{"store_id":"ST-001","movements":[` + join(ms) + `]}`
}

func join(s []string) string {
	out := ""
	for i, x := range s {
		if i > 0 {
			out += ","
		}
		out += x
	}
	return out
}

var contractCases = []contractCase{
	{"salud", "GET", "/health", "", 200, jsonField("status", "ok")},
	{"sincroniza un lote", "POST", "/sync/batches", syncBody("1", "2", "3"), 200, jsonField("accepted", 3)},
	{"reenviar el lote no duplica", "POST", "/sync/batches", syncBody("1", "2", "3"), 200, jsonField("duplicates", 3)},
	{"tipo desconocido es 400", "POST", "/sync/batches",
		`{"store_id":"ST-001","movements":[{"external_ref":"x","type":"gift","amount_minor":1,"currency":"COP","occurred_at":"2030-01-15T15:04:05Z"}]}`,
		400, hasCode("validation_failed")},
	{"JSON roto es 400", "POST", "/sync/batches", `{"store_id":`, 400, hasCode("bad_request")},
	{"tienda inexistente es 404", "POST", "/sync/batches",
		`{"store_id":"ST-999","movements":[{"external_ref":"x","type":"sale","amount_minor":1,"currency":"COP","occurred_at":"2030-01-15T15:04:05Z"}]}`,
		404, hasCode("not_found")},
	{"lee un movimiento", "GET", "/movements/ST-001-" + run + "-2", "", 200, func(t *testing.T, b []byte) {
		jsonField("type", "refund")(t, b)
		jsonField("amount_minor", 2000)(t, b)
		jsonField("occurred_at", "2030-01-15T15:04:05Z")(t, b)
		jsonField("status", "received")(t, b)
	}},
	{"movimiento inexistente es 404", "GET", "/movements/no-existe", "", 404, hasCode("not_found")},
	{"lista con cursor", "GET", "/movements?store=ST-001&limit=2&cursor=ST-001-" + run, "", 200, func(t *testing.T, b []byte) {
		var p struct {
			Items      []struct{ ID string `json:"id"` } `json:"items"`
			NextCursor string                             `json:"next_cursor"`
		}
		if err := json.Unmarshal(b, &p); err != nil || len(p.Items) != 2 || p.NextCursor != p.Items[1].ID {
			t.Errorf("página inesperada: %s", b)
		}
	}},
	{"lista sin tienda es 400", "GET", "/movements", "", 400, hasCode("validation_failed")},
	{"limit fuera de rango es 400", "GET", "/movements?store=ST-001&limit=9999", "", 400, hasCode("validation_failed")},
	{"lanza el cierre", "POST", "/runs", `{"day":"2030-01-15","chunk_size":2}`, 202, jsonField("id", "b-2030-01-15")},
	{"el mismo cierre otra vez es 409", "POST", "/runs", `{"day":"2030-01-15","chunk_size":2}`, 409, hasCode("conflict")},
	{"día inválido es 400", "POST", "/runs", `{"day":"15/01/2030"}`, 400, hasCode("validation_failed")},
	{"el cierre termina", "GET", "/runs/b-2030-01-15", "", 200, nil},
	{"cierre inexistente es 404", "GET", "/runs/b-1999-01-01", "", 404, hasCode("not_found")},
	{"tras el cierre, la venta está conciliada", "GET", "/movements/ST-001-" + run + "-1", "", 200, jsonField("status", "matched")},
	{"y el void, sin conciliar", "GET", "/movements/ST-001-" + run + "-3", "", 200, jsonField("status", "unmatched")},
}

func TestContract(t *testing.T) {
	base := os.Getenv("CLEARINGHOUSE_URL")
	if base == "" {
		t.Skip("CLEARINGHOUSE_URL no definida")
	}
	for _, tc := range contractCases {
		t.Run(tc.name, func(t *testing.T) {
			if tc.name == "el cierre termina" {
				waitCompleted(t, base+tc.path)
				return
			}
			status, body := do(t, base, tc.method, tc.path, tc.body)
			if status != tc.wantStatus {
				t.Fatalf("%s %s = %d, quería %d: %s", tc.method, tc.path, status, tc.wantStatus, body)
			}
			if tc.wantBodyMatch != nil {
				tc.wantBodyMatch(t, body)
			}
		})
	}
}

func waitCompleted(t *testing.T, url string) {
	deadline := time.Now().Add(30 * time.Second)
	for time.Now().Before(deadline) {
		status, body := do(t, url, "GET", "", "")
		var b struct{ Status string `json:"status"` }
		_ = json.Unmarshal(body, &b)
		if status == 200 && b.Status == "completed" {
			jsonField("processed", 3)(t, body)
			return
		}
		time.Sleep(200 * time.Millisecond)
	}
	t.Fatal("el cierre no terminó en 30 s")
}

func do(t *testing.T, base, method, path, body string) (int, []byte) {
	t.Helper()
	req, err := http.NewRequest(method, base+path, bytes.NewBufferString(body))
	if err != nil {
		t.Fatal(err)
	}
	if body != "" {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	b, _ := io.ReadAll(resp.Body)
	if ct := resp.Header.Get("Content-Type"); len(b) > 0 && !strings.HasPrefix(ct, "application/json") {
		t.Errorf("Content-Type = %q", ct)
	}
	return resp.StatusCode, b
}
