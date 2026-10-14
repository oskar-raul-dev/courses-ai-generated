#!/usr/bin/env python3
"""Wrap the Java fragments of bea-08 (§5 and §8) into Bea08.java, one method per block, as written.
Bare expression statements are wrapped in System.out.println so their value can be compared with the
comment next to them. Usage: CURSO=<course> python3 extraer/t3-java-bea08.py > sondas/java8/bea08/Bea08.java"""
import os, re, subprocess, sys
here = os.path.dirname(os.path.abspath(__file__))
def block(needle, nth=1):
    return subprocess.run([sys.executable, os.path.join(here, "bloque.py"), "bea-08-tiempo-zonas-y-fechas-en-mongo.md", needle, str(nth)],
                          check=True, capture_output=True, text=True).stdout
blocks = [block("Instant now = Instant.now();"), block("new java.util.Date(1789052645123L)"),
          block("TimeZone.getDefault().getID()"), block('OffsetDateTime.parse("2021-07-15T09:00:00-05:00")'),
          block('ZonedDateTime.of(LocalDateTime.parse("2021-03-14T02:30"), ottawa)')]
out = ["import java.time.*;", "import java.util.TimeZone;", "", "public class Bea08 {"]
for i, b in enumerate(blocks):
    out.append(f"  static void block{i}() {{")
    for line in b.splitlines():
        s = line.strip()
        bare = s.endswith(";") and not s.startswith(("System.", "//")) and "=" not in s.split("(")[0] and not re.match(r"^[\w.<>]+\s+\w+\s*=", s)
        if bare:
            expr = s[:-1]
            out.append(f'    System.out.println("  {expr.replace(chr(34), chr(92)+chr(34))[:60]} -> " + {expr});')
        else:
            out.append("    " + line)
    out.append("  }")
out.append("  public static void main(String[] a) {")
out.append('    System.out.println("JVM zone " + TimeZone.getDefault().getID());')
for i in range(len(blocks)):
    out.append(f'    System.out.println("-- bloque {i}"); block{i}();')
out.append("  }\n}")
print("\n".join(out))
