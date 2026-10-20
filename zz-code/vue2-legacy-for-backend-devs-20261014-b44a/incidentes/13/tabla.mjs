import { readFileSync } from "fs";
import { scoreBoard } from "./ticketStats.mjs";
var db = JSON.parse(readFileSync(process.argv[2], "utf8"));
scoreBoard(db.tickets, db.users).forEach(function (r) { console.log(JSON.stringify(r)); });
