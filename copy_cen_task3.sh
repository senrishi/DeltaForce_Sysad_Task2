
censored="/temp_loc/censored.txt"
SCRIPT="/temp_loc/task3.sh"
DIR="/home/moderators"

username=$(yq e '.mods[].username' "$YAML_FILE")
cp "$censored" "$DIR"

for mod in username; do
    cp "$SCRIPT" "$DIR/$mod"
done
