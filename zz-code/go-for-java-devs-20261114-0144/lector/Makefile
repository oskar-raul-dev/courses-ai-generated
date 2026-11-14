# Makefile
# Nota: en Make, cada línea de receta empieza con un TABULADOR, no espacios.

GO         ?= go
GO113      ?= go1.13
COVER_FILE ?= cover.out
COVER_MIN  ?= 80

# El monorepo no tiene un go.mod en la raíz: cada lab y cada servicio es su propio
# módulo, y `go fmt ./...` desde aquí falla con "directory prefix . does not contain
# main module". Hasta que llegue go.work en la Fase 08, cada objetivo recorre los
# módulos uno por uno, y salta los que todavía no tienen ningún .go.
MODULES := $(sort $(patsubst %/go.mod,%,$(shell find . -name go.mod -not -path '*/bin/*')))
EACH     = for m in $(MODULES); do \
             [ -n "$$(find $$m -name '*.go' -print -quit)" ] || continue; \
             (cd $$m && $(1)) || exit 1; \
           done

.PHONY: help fmt vet lint test test-race cover up down clean

help: ## Lista los objetivos disponibles
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

fmt: ## Formatea todo el repositorio
	@$(call EACH,$(GO) fmt ./...)

vet: ## Análisis estático del toolchain
	@$(call EACH,$(GO) vet ./...)

lint: ## golangci-lint con la configuración del curso
	@$(call EACH,golangci-lint run ./...)

test: ## Suite rápida
	@$(call EACH,$(GO) test ./...)

test-race: ## Suite con el detector de carreras
	@$(call EACH,$(GO) test -race ./...)

cover: ## Cobertura con umbral, un total por módulo
	@$(call EACH,$(GO) test -race -covermode=atomic -coverprofile=$(COVER_FILE) ./... >/dev/null && \
		printf '%-40s ' $$m && $(GO) tool cover -func=$(COVER_FILE) | tail -n 1)

up: ## Levanta PostgreSQL, MongoDB y Valkey
	docker compose up -d

down: ## Apaga la infraestructura y borra sus volúmenes
	docker compose down -v

clean: ## Borra binarios y artefactos de cobertura
	@$(call EACH,rm -rf bin $(COVER_FILE))
