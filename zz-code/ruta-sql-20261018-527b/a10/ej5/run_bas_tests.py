"""Runs ModParser.bas + TestParser.bas in LibreOffice Basic, headless, from the command line.

Usage:
    python3 run_bas_tests.py                 # es-AR, years 1930-2029: the front desk PC in 1998
    python3 run_bas_tests.py en-US           # same code, US regional setting: dates flip or vanish
    python3 run_bas_tests.py es-AR default   # LibreOffice's own two-digit year window, not Windows'

Uses an isolated LibreOffice profile under out/lo-profile, so the user's own LibreOffice
configuration is never touched. The only change made to the VBA sources is mechanical:
Access-only lines (Attribute VB_Name, Option Compare Database) are dropped and
Option VBASupport 1 is added on top.
"""

import os
import re
import subprocess
import sys
from pathlib import Path
from xml.sax.saxutils import escape

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
PROFILE = OUT / "lo-profile"
RESULT = OUT / "bas_tests.txt"
MODULES = ["ModParser", "TestParser"]
SOFFICE = "soffice"

ACCESS_ONLY = ("Attribute VB_Name", "Option Compare Database")


def to_libreoffice_basic(source: str) -> str:
    lines = [l for l in source.splitlines() if not l.startswith(ACCESS_ONLY)]
    return "Option VBASupport 1\n" + "\n".join(lines) + "\n"


def write_library(basic_dir: Path) -> None:
    lib = basic_dir / "Standard"
    lib.mkdir(parents=True, exist_ok=True)
    for name in MODULES:
        code = to_libreoffice_basic((HERE / f"{name}.bas").read_text(encoding="utf-8"))
        (lib / f"{name}.xba").write_text(
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            '<!DOCTYPE script:module PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "module.dtd">\n'
            f'<script:module xmlns:script="http://openoffice.org/2000/script" script:name="{name}" '
            f'script:language="StarBasic">{escape(code)}</script:module>\n',
            encoding="utf-8",
        )
    elements = "\n".join(f' <library:element library:name="{m}"/>' for m in MODULES)
    (lib / "script.xlb").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!DOCTYPE library:library PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "library.dtd">\n'
        '<library:library xmlns:library="http://openoffice.org/2000/library" library:name="Standard" '
        'library:readonly="false" library:passwordprotected="false">\n'
        f"{elements}\n</library:library>\n",
        encoding="utf-8",
    )


def set_config(profile_user: Path, path: str, prop: str, value: str | None) -> None:
    """Sets (or removes, with None) one LibreOffice configuration value in the isolated profile."""
    xcu = profile_user / "registrymodifications.xcu"
    text = xcu.read_text(encoding="utf-8")
    text = re.sub(rf'<item oor:path="{re.escape(path)}"><prop oor:name="{prop}".*?</item>\n?', "", text)
    if value is not None:
        item = (f'<item oor:path="{path}"><prop oor:name="{prop}" oor:op="fuse">'
                f"<value>{value}</value></prop></item>\n")
        text = text.replace("</oor:items>", item + "</oor:items>")
    xcu.write_text(text, encoding="utf-8")


def soffice(*args: str) -> None:
    subprocess.run(
        [SOFFICE, f"-env:UserInstallation={PROFILE.as_uri()}", "--headless", "--norestore", *args],
        check=True,
        timeout=120,
        env={**os.environ, "PARSER_TEST_OUT": str(RESULT)},
    )


def main(locale: str, two_digit_start: str) -> int:
    OUT.mkdir(exist_ok=True)
    if not (PROFILE / "user").exists():
        soffice("--terminate_after_init")  # first run creates the profile
    write_library(PROFILE / "user" / "basic")
    # Basic parses dates with the office locale, as VBA used Windows' regional settings.
    set_config(PROFILE / "user", "/org.openoffice.Setup/L10N", "ooSetupSystemLocale", locale)
    # Windows reads 00-29 as 20xx. A fresh LibreOffice profile does not, unless told so.
    set_config(PROFILE / "user", "/org.openoffice.Office.Common/DateFormat", "TwoDigitYear",
               None if two_digit_start == "default" else two_digit_start)
    RESULT.unlink(missing_ok=True)

    soffice("macro:///Standard.TestParser.Main")

    if not RESULT.exists():
        print("LibreOffice ran but produced no output: the macro did not run or failed to compile.")
        return 1
    report = RESULT.read_text(encoding="utf-8")
    print(f"locale {locale}, two-digit years from {two_digit_start}\n")
    print(report)
    return 0 if " 0 failed" in report else 1


if __name__ == "__main__":
    args = sys.argv[1:]
    sys.exit(main(args[0] if args else "es-AR", args[1] if len(args) > 1 else "1930"))
