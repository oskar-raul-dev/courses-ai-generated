import json, subprocess, time, urllib.parse
res = json.load(open("resultado.json"))
yt = sorted({r["url"] for r in res if "youtube.com/watch" in r["url"] or "youtu.be/" in r["url"]})
out = {}
for u in yt:
    q = "https://www.youtube.com/oembed?format=json&url=" + urllib.parse.quote(u, safe="")
    r = subprocess.run(["curl", "-s", "--max-time", "20", "-w", "\n%{http_code}", q], capture_output=True, text=True)
    body, code = r.stdout.rsplit("\n", 1)
    titulo = json.loads(body).get("title", "")[:70] if code == "200" else ""
    out[u] = [code, titulo]
    print(code, u, "|", titulo)
    time.sleep(1.5)
json.dump(out, open("youtube.json", "w"), ensure_ascii=False, indent=1)
