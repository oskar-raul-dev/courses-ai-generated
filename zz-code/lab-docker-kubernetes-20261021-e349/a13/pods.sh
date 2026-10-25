#!/bin/sh
# a13: un pod escribe lo mismo en un PVC y en la carpeta del host montada en el nodo (escribir), o lee los dos (leer).
modo=$1
if [ "$modo" = leer ]; then
  cmd='echo PVC:; cat /datos/pedido.txt; echo "carpeta del host:"; cat /host/pedido.txt'
else
  cmd='echo "pedido de Chapinero" > /datos/pedido.txt; echo "pedido de Chapinero" > /host/pedido.txt'
fi
kubectl --context kind-a13 apply -f - > /dev/null <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: datos, namespace: default}
spec: {accessModes: [ReadWriteOnce], resources: {requests: {storage: 100Mi}}}
---
apiVersion: v1
kind: Pod
metadata: {name: a13-$modo, namespace: default}
spec:
  restartPolicy: Never
  containers:
    - name: c
      image: busybox:latest
      command: ["sh", "-c", '$cmd']
      volumeMounts: [{name: d, mountPath: /datos}, {name: h, mountPath: /host}]
  volumes:
    - {name: d, persistentVolumeClaim: {claimName: datos}}
    - {name: h, hostPath: {path: /respaldos}}
YAML
kubectl --context kind-a13 wait --for=jsonpath='{.status.phase}'=Succeeded pod/a13-$modo --timeout=180s > /dev/null 2>&1 || \
  kubectl --context kind-a13 wait --for=jsonpath='{.status.phase}'=Failed pod/a13-$modo --timeout=5s > /dev/null 2>&1
kubectl --context kind-a13 logs pod/a13-$modo
