// iovalkey contra Valkey: Lua del lado del servidor, pipeline y conteo de viajes.
// Uso: node valkey.mjs <host> <puerto>
import Valkey from "iovalkey";

const [host = "127.0.0.1", port = "6379"] = process.argv.slice(2);
const client = new Valkey({ host, port: Number(port) });

console.log("servidor:", (await client.info("server")).match(/valkey_version:(\S+)/)?.[1]);

// candado de la orden de trabajo abierta: SET NX con expiración, y liberación atómica en Lua
const lockKey = "lock:workOrder:WO-2026-0915";
const token = "terminal-plataforma-2";
console.log("candado 1:", await client.set(lockKey, token, "PX", 30000, "NX"));
console.log("candado 2 (otro terminal):", await client.set(lockKey, "terminal-plataforma-5", "PX", 30000, "NX"));

client.defineCommand("releaseLock", {
  numberOfKeys: 1,
  lua: `if redis.call("GET", KEYS[1]) == ARGV[1] then return redis.call("DEL", KEYS[1]) else return 0 end`,
});
console.log("liberación con token ajeno:", await client.releaseLock(lockKey, "terminal-plataforma-5"));
console.log("liberación con token propio:", await client.releaseLock(lockKey, token));

// pipeline: 100 reservas de puesto en un viaje en lugar de 100
const before = Number((await client.info("stats")).match(/total_commands_processed:(\d+)/)[1]);
const p = client.pipeline();
for (let i = 0; i < 100; i++) p.hset(`slot:VVC-foso-${i % 3}:${i}`, "aircraft", `HK-${4000 + i}`);
const results = await p.exec();
const after = Number((await client.info("stats")).match(/total_commands_processed:(\d+)/)[1]);
console.log(`pipeline: ${results.length} respuestas, errores: ${results.filter(([e]) => e).length}, comandos en el servidor: ${after - before - 1}`);

await client.flushdb();
await client.quit();
