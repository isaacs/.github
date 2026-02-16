#!/bin/bash

if ! [ -f package.json ]; then
  exit 0
fi

DOTDIR=$(cd -- $(dirname "$0") &>/dev/null; pwd -P)

remote="$(node -e '
const re = /github.com[:\/]([^\/]+)\/(.*)$/
const u = process.argv[1].replace(/\.git$/, "")
const m = u.match(re)
if (!m) process.exit()
console.log(`https://github.com/${m[1]}/${m[2]}`)
' $(git remote get-url origin))"

if ! [ "$remote" = "" ]; then
  cat > typedoc.json <(
    cat $DOTDIR/typedoc.json | sed -E 's#\$\{remote\}#'$remote'#g'
  )
fi

# remove prettier configs from package.json, standard indentation
node -e '
const { readFileSync, writeFileSync } = require("node:fs")
const { prettier, ...pkg } = JSON.parse(readFileSync("package.json"))
if (typeof pkg.tap === "object") {
  writeFileSync(".taprc", JSON.stringify(pkg.tap, null, 2) + "\n")
  delete pkg.tap
}
writeFileSync("package.json", JSON.stringify(pkg, null, 2) + "\n")
'

cp "$DOTDIR/.prettierignore" .
cp "$DOTDIR/.prettierrc.json" .


NODE_VERSION="22.x, 24.x"
ACTION_SETUP_NODE=actions/setup-node@v6
ACTION_CHECKOUT=actions/checkout@v6
ACTION_CONFIGURE_PAGES=actions/configure-pages@v5
ACTION_UPLOAD_PAGES_ARTIFACT=actions/upload-pages-artifact@v4
ACTION_DEPLOY_PAGES=actions/deploy-pages@v4

rm -rf .github/workflows
mkdir -p .github/workflows

cat > .github/workflows/typedoc.yml <(
  cat "$DOTDIR/typedoc.yml" \
    | sed -E 's#\$\{NODE_VERSION\}#'"${NODE_VERSION}"'#g' \
    | sed -E 's#\$\{ACTION_SETUP_NODE\}#'"${ACTION_SETUP_NODE}"'#g' \
    | sed -E 's#\$\{ACTION_CHECKOUT\}#'"${ACTION_CHECKOUT}"'#g' \
    | sed -E 's#\$\{ACTION_CONFIGURE_PAGES\}#'"${ACTION_CONFIGURE_PAGES}"'#g' \
    | sed -E 's#\$\{ACTION_UPLOAD_PAGES_ARTIFACT\}#'"${ACTION_UPLOAD_PAGES_ARTIFACT}"'#g' \
    | sed -E 's#\$\{ACTION_DEPLOY_PAGES\}#'"${ACTION_DEPLOY_PAGES}"'#g'
)

cat > .github/workflows/ci.yml <(
  cat "$DOTDIR/ci.yml" \
    | sed -E 's#\$\{NODE_VERSION\}#'"${NODE_VERSION}"'#g' \
    | sed -E 's#\$\{ACTION_SETUP_NODE\}#'"${ACTION_SETUP_NODE}"'#g' \
    | sed -E 's#\$\{ACTION_CHECKOUT\}#'"${ACTION_CHECKOUT}"'#g' \
    | sed -E 's#\$\{ACTION_CONFIGURE_PAGES\}#'"${ACTION_CONFIGURE_PAGES}"'#g' \
    | sed -E 's#\$\{ACTION_UPLOAD_PAGES_ARTIFACT\}#'"${ACTION_UPLOAD_PAGES_ARTIFACT}"'#g' \
    | sed -E 's#\$\{ACTION_DEPLOY_PAGES\}#'"${ACTION_DEPLOY_PAGES}"'#g'
)
