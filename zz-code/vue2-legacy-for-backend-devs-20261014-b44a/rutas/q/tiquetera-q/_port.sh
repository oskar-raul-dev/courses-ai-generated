cd /app
npm install --save-exact vuelidate@0.7.7 bootstrap@4.6.2 chart.js@2.9.4 socket.io-client@2.4.0 lodash@4.17.21 axios@0.21.1 > /tmp/i.log 2>&1; echo "install exit $?"; tail -1 /tmp/i.log
npx quasar build > /tmp/b.log 2>&1; echo "build exit $?"
sed "s/\x1b\[[0-9;]*m//g" /tmp/b.log | grep -E "error|warning|problems|Build succeeded|FAIL" | sort | uniq -c | sort -rn | head -12
