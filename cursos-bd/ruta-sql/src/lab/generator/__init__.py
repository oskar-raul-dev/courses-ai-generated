"""El generador de la caja de Alameda: `generate(profile, seed, out)`.

Misma semilla, mismos bytes: cada tabla tiene su propio flujo aleatorio, y el `MANIFIESTO.json`
de cada perfil guarda el SHA-256 de cada archivo y el de la caja entera.
"""

import csv
import hashlib
import importlib.resources
import json
import os
import shutil
import time

from . import antibiogramas, rubens_parser, schema, tables, world

DEFAULT_SEED = 1996
FORMAT_VERSION = 1


def tsql_script() -> str:
    """El script de creación de ALAMEDA, con la forma que le da el Management Studio."""
    out = ["USE [master]", "GO", "CREATE DATABASE [ALAMEDA]", "GO", "USE [ALAMEDA]", "GO"]
    for t in schema.TABLES.values():
        out += ["SET ANSI_NULLS ON", "GO", "SET QUOTED_IDENTIFIER ON", "GO", f"CREATE TABLE [dbo].[{t.name}]("]
        cols = []
        for c in t.columns:
            base, _, size = c.tsql.partition("(")
            kind = f"[{base}]" + (f"({size}" if size else "")
            null = "NOT NULL" if c.name == t.primary_key or c.identity else "NULL"
            ident = f" {c.identity}" if c.identity else ""
            cols.append(f"\t[{c.name}] {kind}{ident} {null}")
        if t.primary_key:
            cols.append(f" CONSTRAINT [PK_{t.name.replace(' ', '_')}] PRIMARY KEY CLUSTERED \n(\n\t[{t.primary_key}] ASC\n)"
                        "WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, "
                        "ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]")
        out.append(",\n".join(cols))
        out += [") ON [PRIMARY]", "GO"]
    out.append("-- 2011: las llaves foraneas se agregaron con NOCHECK para que no fallen con lo que ya habia")
    for t in schema.TABLES.values():
        for col, ref, ref_col in t.foreign_keys:
            out += [f"ALTER TABLE [dbo].[{t.name}]  WITH NOCHECK ADD  CONSTRAINT [FK_{t.name}_{ref}] "
                    f"FOREIGN KEY([{col}])", f"REFERENCES [dbo].[{ref}] ([{ref_col}])", "GO",
                    f"ALTER TABLE [dbo].[{t.name}] NOCHECK CONSTRAINT [FK_{t.name}_{ref}]", "GO"]
    return "\r\n".join(out) + "\r\n"


def _assets(box: tables.Box) -> None:
    src = importlib.resources.files(__package__) / "assets"
    for name, dest in [("LEEME.txt", "LEEME.txt"), ("ModParser.bas", "vba/ModParser.bas"),
                       ("ModImportarEquipos.bas", "vba/ModImportarEquipos.bas"),
                       ("ModFolio.bas", "vba/ModFolio.bas"), ("fn_ExtraerDNI.sql", "tsql/fn_ExtraerDNI.sql")]:
        text = (src / name).read_text(encoding="utf-8")
        encoding = "cp1252" if dest.endswith((".bas", ".txt")) else "utf-8"
        with open(box.path(dest), "w", encoding=encoding, newline="\r\n") as fh:
            fh.write(text)
    with open(box.path("esquema/ALAMEDA.sql"), "w", encoding="utf-8", newline="") as fh:
        fh.write(tsql_script())


def _parser_accuracy(w: dict) -> dict:
    """Cuánto acierta el ExtraerDNI de Rubén sobre las filas con un documento escrito en el nombre."""
    total = hits = 0
    for r in w["rows"]:
        if "dni_in_name" in r.dirt:
            total += 1
            hits += rubens_parser.extract_dni(r.name) == r.expected_dni
    return {"rows_with_document_in_name": total, "extract_dni_matches_truth": hits,
            "accuracy": round(hits / total, 4) if total else None}


def _fire_test(root: str) -> dict:
    """La prueba de fuego de la Fase 01: cuántos `Nombre` de Pacientes contienen `DNI`, contado sobre
    el CSV ya escrito, que es lo mismo que va a contar el lector con un LIKE después de cargarlo."""
    with open(os.path.join(root, "tablas", "Pacientes.csv"), encoding="latin-1", newline="") as fh:
        n = sum("DNI" in (row["Nombre"] or "") for row in csv.DictReader(fh))
    return {"Pacientes.Nombre LIKE '%DNI%'": n}


def _sha256(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for block in iter(lambda: fh.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def generate(profile: str = "s", seed: int = DEFAULT_SEED, out: str = "caja", log=print) -> dict:
    root = os.path.join(out, profile)
    if os.path.exists(root):
        shutil.rmtree(root)
    started = time.time()
    box = tables.Box(root, seed)
    people = world.make_people(seed, world.PROFILES[profile])
    lady, grandson = world.plant(people)
    rows = world.make_patient_rows(seed, people, lady, grandson)
    protocols = world.make_protocols(seed, rows, lady)
    w = dict(people=people, rows=rows, protocols=protocols, lady=lady, grandson=grandson,
             doctors=max(120, len(people) // 160))
    log(f"mundo: {len(people)} personas, {len(rows)} filas de Pacientes, {len(protocols)} protocolos "
        f"({time.time() - started:.0f} s)")
    steps = [tables.write_people, tables.write_patients, tables.write_catalogs, tables.write_protocols,
             tables.write_protocol_practices, tables.write_results, tables.write_wide, tables.write_prices,
             tables.write_cash, tables.write_misc, tables.write_appointments, tables.write_files_listing,
             tables.write_spreadsheets, antibiogramas.write_antibiograms]
    for step in steps:
        step(box, w)
        log(f"  {step.__name__} ({time.time() - started:.0f} s)")
    _assets(box)
    files = {}
    for dirpath, _dirs, names in os.walk(root):
        for name in names:
            full = os.path.join(dirpath, name)
            files[os.path.relpath(full, root).replace(os.sep, "/")] = _sha256(full)
    whole = hashlib.sha256("".join(f"{k}:{files[k]}\n" for k in sorted(files)).encode()).hexdigest()
    manifest = {
        "format": FORMAT_VERSION, "profile": profile, "seed": seed, "sha256": whole,
        "people": len(people), "patients": len(rows), "protocols": len(protocols),
        "rows": dict(sorted(box.counts.items())),
        "encodings": {t.file: t.encoding for t in schema.TABLES.values() if t.encoding != "utf-8"},
        "parser": _parser_accuracy(w),
        "fire_test": _fire_test(root),
        "files": dict(sorted(files.items())),
    }
    with open(os.path.join(root, "MANIFIESTO.json"), "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, ensure_ascii=False, indent=1)
    manifest["seconds"] = round(time.time() - started)
    return manifest
