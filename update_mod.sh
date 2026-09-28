#!/usr/bin/env bash
# Авто-обнова mod.js: качает свежий клиент devast.io, деобфусцирует,
# прогоняет auto_port.py и пушит результат в этот репозиторий.
# Запускать из корня репо после того, как devast.io обновил клиент:
#   ./update_mod.sh
set -euo pipefail

export PATH=/home/ubuntu/pipeline/node/bin:$PATH
PROJ=/home/ubuntu/ziptest/project
WORK=/tmp/client_latest
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

rm -rf "$WORK" && mkdir -p "$WORK"
cd "$WORK"

# 1. свежий клиент
INDEX=$(curl -s https://devast.io/)
JS=$(printf '%s' "$INDEX" | grep -o 'js/[A-Za-z0-9_-]*\.js' | head -1)
echo "client: $JS"
curl -s "https://devast.io/$JS" -o client.js
[ -s client.js ] || { echo "FAIL: client empty"; exit 1; }

# 2. деобфускация + постпроцесс
webcrack client.js -o out
cd "$PROJ"
python3 -c "import devast_tracker, pathlib; devast_tracker.postprocess_dir(pathlib.Path('$WORK/out'))"

# 3. сборка мода
python3 auto_port.py "$WORK/out/deobfuscated.js" -o /tmp/mod_new.js
node --check /tmp/mod_new.js

# 4. пуш в репо
cp /tmp/mod_new.js "$REPO_DIR/mod.js"
cp /tmp/mod_new.js "$PROJ/full.js"
cd "$REPO_DIR"
git add mod.js update_mod.sh
git commit -m "Update mod.js (client $JS)" || echo "no changes"
git push origin main
echo "DONE: mod.js updated"
