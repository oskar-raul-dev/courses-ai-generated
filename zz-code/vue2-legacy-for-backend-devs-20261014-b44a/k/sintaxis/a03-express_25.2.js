var __o = {
app.use(logger);           // 1º
app.use(express.json());   // 2º
app.use("/tickets", ticketsRouter);   // 3º
app.use(notFound);         // 4º  (si nadie respondió antes)
app.use(errorHandler);     // 5º  (el de 4 argumentos: solo si hubo error)
};