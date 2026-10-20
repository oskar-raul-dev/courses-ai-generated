req.params.id        // de la ruta /:id
req.query.status     // del ?status=open        ⚠️ TODO llega como string... o como OBJETO
req.body             // parseado (si hubo parser Y content-type correcto)
req.headers.authorization
req.user             // ⬅️ NO existe: lo pone TU middleware de auth (F11). Convención, no API

res.status(201).json(x)
res.status(204).end()
res.set("Content-Type", ...)     // F12: los streams
res.sendStatus(404)              // status + cuerpo de texto: OJO, rompe el contrato JSON