#!/usr/bin/env bash

set -e

echo "=== ENTRYPOINT: Starting up Realm-Velocity container ==="

CONFIG_DIR="/config"
TARGET_DIR="/opt/velocity"

# 1) Copy config files if the directory exists
if [ -d "$CONFIG_DIR" ]; then
    if [ -z "$(ls -A "$CONFIG_DIR")" ]; then
        echo "WARNING: Config directory exists but is empty: $CONFIG_DIR"
    else
        echo "Copying config files from $CONFIG_DIR to $TARGET_DIR..."
        find "$CONFIG_DIR" -type f | while read -r file; do
            rel_path="${file#$CONFIG_DIR/}" # Get relative path
            target_path="$TARGET_DIR/$rel_path"

            # Ensure the parent directory structure exists in the target directory
            mkdir -p "$(dirname "$target_path")"

            # Only allow .properties, .yml, .yaml, and .json files
            case "$file" in
                *.properties|*.yml|*.yaml|*.json)
                    echo " - Copying $file -> $target_path"
                    cp "$file" "$target_path"
                    ;;
                *)
                    echo "WARNING: Ignoring unsupported config file: $file"
                    ;;
            esac
        done
    fi
else
    echo "WARNING: Config directory $CONFIG_DIR does not exist!"
fi

# 2) Download the latest plugins from Harbor
if [ -n "$PLUGIN_LIST" ]; then
    echo "Downloading plugins from Harbor..."
    mkdir -p /opt/velocity/plugins
    for pluginURL in $PLUGIN_LIST; do
        echo " - Downloading plugin from $pluginURL"
        curl -fSL "$pluginURL" -o "/opt/velocity/plugins/$(basename "$pluginURL")"
    done
else
    echo "No plugins to download. (PLUGIN_LIST is empty)"
fi

# 3) Finally, launch Velocity
echo "=== ENTRYPOINT: Starting Velocity JAR ==="
exec java -jar /opt/velocity/velocity.jar
