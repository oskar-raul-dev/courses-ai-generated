const app = express();

app.use(morgan("dev"));               // ① log de requests
app.use(cors());                      // ② el navegador y su Same-Origin Policy
app.use(express.json({ limit: "1mb" }));   // ③ el body parser
app.use(helmet());                    // ④ cabeceras de seguridad (A4)

app.use("/tickets", ticketsRouter);   // ⑤ router montado con prefijo
app.use("/comments", commentsRouter);

app.use(notFound);                    // ⑥ nadie respondió → 404
app.use(errorHandler);                // ⑦ 4 args, el último