# rescatado de la sesión 2924cb25, 2026-09-11T16:20:51Z · Verify tag convention and chaos flags
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== tags de fase (convención) ==="; grep -n 'fase-0\|fase-1\|slug' 00-convencion-de-git-y-tags.md | head -30
echo; echo "=== CHAOS flags en fase 3 ==="; grep -n 'CHAOS' 03-mock-api-caos.md | head -30
