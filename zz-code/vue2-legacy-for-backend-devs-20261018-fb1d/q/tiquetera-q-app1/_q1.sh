cd /app
rm -rf package-lock.json
npm install > /tmp/inst.log 2>&1; echo "install exit $?"; tail -2 /tmp/inst.log
for m in vue vue-template-compiler quasar @quasar/app vuex vue-router; do printf "%s " $m; node -p "require('$m/package.json').version"; done
npm i -g jsdom@16.7.0 > /tmp/jsdom.log 2>&1
cat > /tmp/render.js <<'J'
const { JSDOM } = require("/usr/local/lib/node_modules/jsdom");
const path = require("path");
const file = path.resolve(process.argv[2]);
JSDOM.fromFile(file, { runScripts: "dangerously", resources: "usable", pretendToBeVisual: true, url: "file://" + file }).then(function (dom) {
  const errs = [];
  dom.window.console.error = function () { errs.push([].join.call(arguments, " ")); };
  dom.window.console.warn = function () { errs.push([].join.call(arguments, " ")); };
  setTimeout(function () {
    const html = dom.window.document.body.innerHTML;
    console.log("crudo <q-chip>:", (html.match(/<q-chip/g) || []).length, "| renderizado class=q-chip:", (html.match(/class="q-chip /g) || []).length, "| q-toolbar renderizado:", (html.match(/class="q-toolbar /g) || []).length);
    console.log("consola:", errs.length ? errs.join(" || ").slice(0, 300) : "(nada)");
    process.exit(0);
  }, 4000);
});
J
build () { npx quasar build > /tmp/build.log 2>&1; echo "build exit $?"; grep -l "q-chip__content" dist/spa/js/*.js | wc -l | xargs echo "bundles con QChip:"; node /tmp/render.js dist/spa/index.html; }
echo "== sin QChip en la lista"; build
sed "s/\x1b\[[0-9;]*m//g" /tmp/build.log | grep -i "warn\|error\|Build succeeded\|Compiled" | head -5
echo "== con QChip en la lista"; sed -i "s/'QToolbar', 'QToolbarTitle', 'QBtn', 'QIcon',/'QToolbar', 'QToolbarTitle', 'QBtn', 'QIcon', 'QChip',/" quasar.conf.js; build
echo "== debug (modo desarrollo de Vue)"; sed -i "s/'QIcon', 'QChip',/'QIcon',/" quasar.conf.js; npx quasar build --debug > /tmp/buildd.log 2>&1; echo "debug exit $?"; node /tmp/render.js dist/spa/index.html
