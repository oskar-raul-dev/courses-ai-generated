cd /app
npm uninstall vuelidate > /tmp/u.log 2>&1; echo "uninstall exit $?"
npx quasar build > /tmp/b.log 2>&1; echo "build exit $?"
sed "s/\x1b\[[0-9;]*m//g" /tmp/b.log | grep -iE -A3 "error|not found|FAIL" | head -24
npx jest tests/unit/regression/ticketForm.spec.js --ci 2>&1 | sed -n 1,25p
