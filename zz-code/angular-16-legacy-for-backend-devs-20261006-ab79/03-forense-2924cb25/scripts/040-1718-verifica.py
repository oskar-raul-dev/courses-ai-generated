# rescatado de la sesión 2924cb25, 2026-09-11T17:18:08Z · Verify the new phase document
import re,os
f='be00-el-contrato-auditoria-del-mock.md'
for m in re.finditer(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)', open(f).read()):
    if not os.path.exists(m.group(1)): print('ROTO ->',m.group(1))
print('ok')
