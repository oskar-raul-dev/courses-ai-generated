cd /app
npm install --save-dev --save-exact @vue/cli-plugin-unit-jest@3.12.1 @vue/test-utils@1.3.6 babel-core@7.0.0-bridge.0 > /tmp/i.log 2>&1; echo "install exit $?"
for m in jest babel-jest vue-jest @vue/test-utils @babel/preset-env @babel/core; do printf "%s " $m; node -p "require('$m/package.json').version"; done
npm run test:unit -- --ci 2>&1 | tail -40
