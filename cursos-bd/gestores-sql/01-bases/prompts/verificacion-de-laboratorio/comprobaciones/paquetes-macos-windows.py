# P8: qué versión publica cada gestor de paquetes de macOS y Windows (consulta, no instalación).
import json, re, urllib.request as u

def get(url):
    r = u.urlopen(u.Request(url, headers={"User-Agent": "mdm-p8"}), timeout=30)
    return r.status, r.read().decode()

def show(label, fn):
    try:
        print(label, *fn())
    except Exception as e:
        print(label, "ERROR", e)

def brew(name):
    s, b = get(f"https://formulae.brew.sh/api/formula/{name}.json"); j = json.loads(b)
    return s, j["versions"]["stable"], "keg_only" if j["keg_only"] else ""

def scoop(name):
    s, b = get(f"https://raw.githubusercontent.com/ScoopInstaller/Main/master/bucket/{name}.json")
    return s, json.loads(b)["version"]

def winget(path):
    s, b = get(f"https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/{path}")
    return s, sorted(x["name"] for x in json.loads(b))[-3:]

def choco(pkg):
    s, b = get(f"https://community.chocolatey.org/api/v2/Packages()?$filter=Id%20eq%20%27{pkg}%27%20and%20IsLatestVersion")
    return s, re.findall(r"<d:Version>([^<]+)", b)

show("brew sqlite", lambda: brew("sqlite"))
show("brew python@3.14", lambda: brew("python@3.14"))
show("scoop main/sqlite", lambda: scoop("sqlite"))
show("scoop main/python", lambda: scoop("python"))
show("winget SQLite.SQLite", lambda: winget("s/SQLite/SQLite"))
show("winget Python.Python.3.14", lambda: winget("p/Python/Python/3/14"))
show("choco sqlite", lambda: choco("sqlite"))
show("choco sqlite.shell", lambda: choco("sqlite.shell"))
show("choco python", lambda: choco("python"))

# Bloque A.C.: GnuCOBOL y Harbour.
show("brew gnucobol", lambda: brew("gnucobol"))
show("brew harbour", lambda: brew("harbour"))
show("scoop main/gnucobol", lambda: scoop("gnucobol"))
show("winget GnuCOBOL", lambda: winget("g/GnuCOBOL"))
show("winget Harbour", lambda: winget("h/Harbour"))
show("choco gnucobol", lambda: choco("gnucobol"))
show("choco harbour", lambda: choco("harbour"))
def gh(repo):
    s, b = get(f"https://api.github.com/repos/{repo}"); j = json.loads(b)
    s2, b2 = get(f"https://api.github.com/repos/{repo}/releases?per_page=3")
    return s, "pushed_at", j["pushed_at"], "archived", j["archived"], [r["tag_name"] for r in json.loads(b2)]
show("github harbour/core", lambda: gh("harbour/core"))
