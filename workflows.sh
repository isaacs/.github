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

HAS_BUILD=$([ -f scripts/build.sh ] && echo 1 || echo 0)

# remove prettier configs from package.json, standard indentation
node -e '
HAS_BUILD = process.argv[1] === "1"
const { statSync, readFileSync, writeFileSync } = require("node:fs")
const { prettier, ...pkg } = JSON.parse(readFileSync("package.json"))
if (typeof pkg.tap === "object") {
  writeFileSync(".taprc", JSON.stringify(pkg.tap, null, 2) + "\n")
  delete pkg.tap
}

pkg.scripts ??= {}
pkg.scripts.test ??= "tap"
pkg.scripts.snap ??= "tap"
try {
  statSync("scripts/build.sh")
  pkg.scripts.prepare ??= "tshy && bash scripts/build.sh"
} catch {
  pkg.scripts.prepare ??= "tshy"
}
pkg.scripts.typedoc ??= "typedoc"
pkg.scripts.prepublishOnly ??= "git push origin --follow-tags"
pkg.scripts.pretest ??= "npm run prepare"
pkg.scripts.presnap ??= "npm run prepare"
pkg.scripts.lint ??= "oxlint --fix src test"
pkg.scripts.format ??= "prettier --write ."
pkg.scripts.postsnap ??= "npm run lint"
pkg.scripts.postlint ??= "npm run format"

pkg.tshy ??= {
  selfLink: false,
  compiler: "tsgo",
  exports: {
    ".": "./src/index.ts",
    "./package.json": "./package.json",
  },
}
pkg.tshy.selfLink = false

writeFileSync("package.json", JSON.stringify(pkg, null, 2) + "\n")
' "$HAS_BUILD"

cp "$DOTDIR/.prettierignore" .
cp "$DOTDIR/.prettierrc.json" .
cp "$DOTDIR/.oxlintrc.json" .

PKGS=(
  "typedoc@latest"
  "tap@latest"
  "prettier@latest"
  "oxlint@latest"
  "oxlint-tsgolint@latest"
  "tshy@latest"
  "@types/node@latest"
)

if [ "$HAS_BUILD" -eq 1 ]; then
  if [ "$(cat scripts/build.sh)" = "" ]; then
    cp "$DOTDIR/build.sh" ./scripts
  fi
  PKGS+=("esbuild@latest")
fi

npm i -D "${PKGS[@]}"

NODE_VERSION="22.x, 24.x, 25.x"
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
