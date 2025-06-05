YAML_FILE="/home/scripts/sysad-1-users.yaml"
SCRIPT="/temp_loc/task2.sh"
DIR="/home/authors"

username=$(yq e '.authors[].username' "$YAML_FILE")

for user in username; do
    cp "$SCRIPT" "$DIR/$user"
done
