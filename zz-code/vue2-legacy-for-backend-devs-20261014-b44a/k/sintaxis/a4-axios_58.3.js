var __a = [
apiClient.get("/tickets", {
  params: { status: "open", _sort: "createdAt" }  // → ?status=open&_sort=createdAt
});

apiClient.post("/tickets", payload);          // el 2º argumento ES el body
apiClient.patch("/tickets/" + id, changes);   // parcial (F3: PATCH vs PUT)
apiClient.delete("/tickets/" + id);

// forma general equivalente:
apiClient({ method: "get", url: "/tickets", params: {...}, data: {...} });
];