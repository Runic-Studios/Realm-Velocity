#!/usr/bin/env sh

set -euxo pipefail

inflate() {
  src=$1
  dest=$2

  mkdir -p "$dest"

  find "$src" -maxdepth 1 -type f | while read -r file; do
    base=$(basename "$file")
    path=$(echo "$base" | sed 's/__/\//g')
    mkdir -p "$dest/$(dirname "$path")"
    cp "$file" "$dest/$path"
  done
}

# Inflate base and env overlays
inflate /overlays/base /inflated/base
inflate /overlays/env /inflated/env

# Inject the configuration files from config volume into velocity
./palimpsest -o /opt/velocity -o /inflated/base -o /inflated/env -t /opt/velocity

exec java -Xms1024M -Xmx1024M -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:MaxInlineLevel=15 -jar velocity.jar &
pid=$!
# Trap the SIGTERM signal and forward it to the main process (15 = SIGTERM)
trap 'kill -15 $pid; wait $pid' SIGTERM
wait $pid
