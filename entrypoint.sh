#!/usr/bin/env bash

set -e

echo "=== ENTRYPOINT: Starting up Realm-Velocity container ==="

CONFIG_DIR="/config"
TARGET_DIR="/opt/velocity"

# Copy config files if the directory exists
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

# Finally, launch Velocity
echo "=== ENTRYPOINT: Starting Velocity JAR ==="
exec java -jar /opt/velocity/velocity.jar
