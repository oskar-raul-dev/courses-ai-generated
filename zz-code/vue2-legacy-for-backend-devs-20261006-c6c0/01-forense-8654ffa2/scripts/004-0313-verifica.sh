# rescatado de la sesión 8654ffa2, 2026-09-09T03:13:30Z · Check appendix tags and exercise tag section
cd ../angular-16-legacy-for-backend-devs && echo "=== A16: apéndices en la convención ===" && grep -n -i 'apéndice\|apendice\|a09\|a12' 00-convencion-de-git-y-tags.md | head -10
echo; echo "=== A16 §🧪 tags de ejercicios ===" && sed -n '195,249p' 00-convencion-de-git-y-tags.md
echo; echo "=== A8 outline ===" && grep -n '^#\{1,3\} ' ../angular-8-legacy-for-backend-devs/00-convencion-de-git-y-tags.md
