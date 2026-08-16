# =============================================================
# Makefile — comandos de alto nivel para microk8s-lab
#
# NOTA: en Windows, usa estos comandos como referencia y ejecútalos
# a mano en PowerShell, o instala "make" (via winget o chocolatey).
# Cada target documenta el comando equivalente.
#
# Uso: make <target>
# =============================================================

CLUSTER := lab
CHART   := charts/platform
SERVICES := catalog-node payments-go orders-java web-legacy

.PHONY: help
help:  ## Muestra esta ayuda
	@echo "Targets disponibles:"
	@echo "  make cluster-up      Crea el cluster kind multi-nodo"
	@echo "  make cluster-down    Borra el cluster"
	@echo "  make build           Construye las 4 imagenes con podman"
	@echo "  make load            Carga las imagenes a kind"
	@echo "  make deploy-local    Instala el umbrella (ambiente local)"
	@echo "  make upgrade-local   Actualiza el release local"
	@echo "  make undeploy        Desinstala el release"
	@echo "  make status          Muestra pods y releases"
	@echo "  make all-local       build + load + deploy-local"

.PHONY: cluster-up
cluster-up:  ## Crea el cluster kind
	kind create cluster --config kind/cluster.yaml --name $(CLUSTER)

.PHONY: cluster-down
cluster-down:  ## Borra el cluster
	kind delete cluster --name $(CLUSTER)

.PHONY: build
build:  ## Construye todas las imagenes
	podman build -t localhost/catalog-node:dev services/catalog-node
	podman build -t localhost/payments-go:dev  services/payments-go
	podman build -t localhost/orders-java:dev  services/orders-java
	podman build -t localhost/web-legacy:dev   services/web-legacy

.PHONY: load
load:  ## Carga las imagenes al cluster kind
	kind load docker-image localhost/catalog-node:dev --name $(CLUSTER)
	kind load docker-image localhost/payments-go:dev  --name $(CLUSTER)
	kind load docker-image localhost/orders-java:dev  --name $(CLUSTER)
	kind load docker-image localhost/web-legacy:dev   --name $(CLUSTER)

.PHONY: deploy-local
deploy-local:  ## Instala el umbrella en ambiente local
	helm install $(CLUSTER) $(CHART) \
		-f $(CHART)/values.yaml \
		-f $(CHART)/values-local.yaml

.PHONY: upgrade-local
upgrade-local:  ## Actualiza el release local
	helm upgrade $(CLUSTER) $(CHART) \
		-f $(CHART)/values.yaml \
		-f $(CHART)/values-local.yaml

.PHONY: undeploy
undeploy:  ## Desinstala el release
	helm uninstall $(CLUSTER)

.PHONY: status
status:  ## Muestra el estado
	helm list
	kubectl get pods -o wide

.PHONY: all-local
all-local: build load deploy-local  ## Build + load + deploy en local
