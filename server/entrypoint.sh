#!/usr/bin/env sh

# Inject the configuration files from config volume into velocity
for file in /overlay/*; do
  base=$(basename "$file")
  path=$(echo "$base" | sed 's/__/\//g')
  mkdir -p "/opt/velocity/$(dirname "$path")"
  cp "$file" "/opt/velocity/$path"
done

exec java -Xms1024M -Xmx1024M -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:MaxInlineLevel=15 -jar velocity.jar &
pid=$!
# Trap the SIGTERM signal and forward it to the main process (15 = SIGTERM)
trap 'kill -15 $pid; wait $pid' SIGTERM
wait $pid
