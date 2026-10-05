# P9: cada DOI de la lista de papers, resuelto contra Crossref (título, año, revista, autores).
import json, sys, urllib.request as u

DOIS = """
10.1145/362384.362685 10.1145/320434.320440 10.1145/320557.320571 10.1145/582095.582120
10.1145/320493.320489 10.1145/320083.320091 10.1007/BF00288683 10.1145/356770.356776
10.1007/s002360050048 10.1145/582095.582099 10.1109/69.273032 10.1145/360363.360369
10.1145/223784.223785 10.1145/128765.128770 10.1145/289.291 10.1145/319566.319567
10.1145/320473.320482 10.1145/320083.320092 10.1145/3685980.3685984 10.1145/355611.362534
10.1561/1900000002 10.1145/320107.320109 10.1145/356662.356668 10.1145/356662.356667
""".split()

for doi in DOIS:
    try:
        r = u.urlopen(u.Request(f"https://api.crossref.org/works/{doi}",
                                headers={"User-Agent": "mdm-p9 (mailto:oskarcah@gmail.com)"}), timeout=40)
        m = json.loads(r.read())["message"]
        year = (m.get("published-print") or m.get("published-online") or m.get("issued"))["date-parts"][0][0]
        authors = ", ".join(a.get("family", "?") for a in m.get("author", [])[:4])
        print(f"{doi} | {year} | {authors} | {m['title'][0][:90]} | {(m.get('container-title') or [''])[0][:50]} | {m.get('volume','')}({m.get('issue','')}) {m.get('page','')}")
    except Exception as e:
        print(doi, "ERROR", e)
