# rescatado de la sesión 8654ffa2, 2026-09-09T04:07:12Z · Verify claims, git status, tuteo and links
echo "=== a3-npm: eslint/config? ===" && grep -n -i 'eslint\|lint\|\.npmrc\|config' 01-vue2-legacy/a3-npm.md | head -8
echo; echo "=== git status ===" && git status --short
echo; echo "=== voseo check ===" && grep -nE '\b(tenés|querés|podés|hacés|sabés|debés|mirá|fijate|andá|poné|dale que|vos)\b' prompts/convencion-de-git-y-tags.md | head
echo; echo "=== enlaces relativos ===" && grep -oE '\]\(\.\./?[^)]*\)|\]\([a-z0-9-]+\.md[^)]*\)' prompts/convencion-de-git-y-tags.md | sort -u
