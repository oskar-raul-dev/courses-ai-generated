import sys, re; sys.path.insert(0, "/src")
from lab.engines import sqlserver
Q = {"json_value": "SELECT COUNT(*) FROM staging.culture_doc WHERE JSON_VALUE(antibiogram, '$.MEROPENEM') = 'R'",
     "json_contains": "SELECT COUNT(*) FROM staging.culture_doc WHERE JSON_CONTAINS(antibiogram, 'R', '$.MEROPENEM') = 1",
     "columna_calculada": "SELECT COUNT(*) FROM staging.culture_doc WHERE meropenem = 'R'",
     "json_value_cipro": "SELECT COUNT(*) FROM staging.culture_doc WHERE JSON_VALUE(antibiogram, '$.CIPROFLOXACINA') = 'R'"}
def plan(cur, sql, private=False):
    cur.execute("SET QUOTED_IDENTIFIER ON")
    cur.execute("SET STATISTICS XML ON" if private else "SET SHOWPLAN_XML ON")
    cur.execute(sql); xml = None
    while True:
        if cur.description:
            for r in cur.fetchall():
                if isinstance(r[0], str) and r[0].lstrip().startswith("<ShowPlanXML"): xml = r[0]
        if not cur.nextset(): break
    cur.execute("SET STATISTICS XML OFF" if private else "SET SHOWPLAN_XML OFF")
    return xml
c = sqlserver.connect("ss05"); cur = c.cursor()
for fase in ("con índices", "sin índices"):
    if fase == "sin índices":
        cur.execute("SET QUOTED_IDENTIFIER ON; DROP INDEX IF EXISTS culture_doc_ji ON staging.culture_doc; DROP INDEX IF EXISTS culture_doc_meropenem_idx ON staging.culture_doc")
    for name, sql in Q.items():
        xml = plan(cur, sql)
        print(f"== {fase} · {name}"); print("\n".join("  " + l for l in sqlserver.plan_lines(xml)))
        x2 = plan(cur, sql, True)
        print("  🔒 PRIVADO lecturas", sum(int(v) for v in re.findall(r'ActualLogicalReads="(\d+)"', x2)))
cur.execute("SET QUOTED_IDENTIFIER ON; CREATE JSON INDEX culture_doc_ji ON staging.culture_doc (antibiogram) FOR ('$'); CREATE INDEX culture_doc_meropenem_idx ON staging.culture_doc (meropenem)")
